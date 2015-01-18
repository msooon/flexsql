#!/bin/bash

# Globale Variablen
SCRIPTNAME=$(basename $0 .sh)

EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10

source ${0%/*}/config 2> /dev/null 

# Variablen für Optionsschalter hier mit Default-Werten vorbelegen
#VERBOSE=n #now in global config
OPTFILE=""
search_pattern=""
item_id=""
show_only=""
grep_only=""
min_catagorys=""
categories="''"
ex_category="''"
offset=""
parameters="" #for history
sort_order="category_match desc, rating desc, date desc" #Standard: Bestbewerteste und neueste zuerst
hits_before_asking=4 #Ask for proceeding if there are more than defined hits
search_date=""
USE_HISTORY=y
KEEP_RESULTS=n
EXCERPT=n

# Funktionen
function usage 
{
	echo "Usage: $SCRIPTNAME [-h] [-v] [-i|-l|-f] [-o hits] [-n num_of_categorys] [-x category_to_exclude] [other options] [-s searchpattern] [-t offset] [categories]" >&2
	echo ""
	echo "-x 	      things to exclude - not implemented yet"
	echo "-c	      count hits - not implemented yet"
	echo "-d        search for date e.g. \">'2010-06-15'\" - not implemented yet " 
	echo "-p        prevent writing history"
	echo "-k        keep results"
	echo "-r        only excerpt of text - not implemented yet"
	echo ""
	[[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

#save args for later
ALL_ARGS=$@

#Parse paremeter
while getopts 'bs:d:f:o:n:x:r:t:w:y:z:eilgamopcvuqkh' OPTION ; do
	case $OPTION in
		c)	count_hits=1
			parameters="$parameters""c" #for history
			;;
		d) #     search_date=" and (substr(date,1,11)$OPTARG or substr(lastModified,1,11)$OPTARG)" # format YYYY-MM-DD e.g. >'2010-09-15'
			search_date=" and (Date(date)$OPTARG OR Date(dateAdded)$OPTARG)"  # format YYYY-MM-DD e.g. >'2010-09-15'
			sort_order="category_match desc, date, rating desc"
			#		search_pattern=$OPTARG #TODO eigenes Feld damit Kombination mit s funktioniert
			parameters="$parameters""d" #for history
			;;
		s) 			search_pattern=$OPTARG
			parameters="$parameters""s" #for history
			;;
		h)        usage $EXIT_SUCCESS
			;;
		f)      field_name=$OPTARG 
			parameters="$parameters""f" #for history 
			;;
		o)      # show only specified number of hits
			show_only=" limit $OPTARG "
			grep_only=" -m$OPTARG"
			parameters="$parameters""o$OPTARG" #for history
			;;
		p)      USE_HISTORY=n 
			;;
		r)      EXCERPT=y    #
						EXCERPT_LINES=$OPTARG
			            parameters="$parameters""r$OPTARG" #for history
									            ;;
		t)      #only in combination with parameter 'o' (LIMIT)
			offset="OFFSET $OPTARG"
			parameters="$parameters""t$OPTARG" #for history
			;;
		v) VERBOSE=y
			parameters="$parameters""v" #for history
			;;
		k)
			KEEP_RESULTS=y
			parameters="$parameters""k" #for history
			;;
		
		\?)        echo "Unbekannte Option \"-$OPTARG\"." >&2
			usage $EXIT_ERROR
			;;
		:)        echo "Option \"-$OPTARG\" benötigt ein Argument." >&2
			usage $EXIT_ERROR
			;;
		*)        echo "Dies kann eigentlich gar nicht passiert sein..."
			>&2
			usage $EXIT_BUG
			;;
	esac
done

> $ramdisk/tag_ids #empty file
> $ramdisk/ref_ids #empty file

# Verbrauchte Argumente überspringen
shift $(( OPTIND - 1 ))

# Eventuelle Tests auf min./max. Anzahl Argumente hier
if (( $# < 1 )) ; then
	echo ""
else
	for ARG ; do
		if [[ $VERBOSE = y ]] ; then
			echo -n "Argument: $ARG"
			echo ""
		fi
		one_category="`basename $ARG`"
		#needed for history
		categories="$categories,$one_category"

	dbquery="select distinct ref_id from term, item, term_item where term_item.term_id=term.id and term_item.item_id=item.id and ref_id in  (select distinct ref_id from term, item, term_item where term.name in ('tag','alias') and item.text='$one_category' and term_item.term_id=term.id and term_item.item_id=item.id);"

	if [[ $VERBOSE = y ]] ; then
		echo $dbquery; echo ""
	fi
	sqlite3 $database "$dbquery" > "$ramdisk/tag_ids"

		if [[ -s "$ramdisk/tag_ids" ]] ; then
	while read tag_id
	do
		dbquery="select distinct term_item.id from term, term_item where term_item.term_id=term.id and term.name in ('tag','alias') and ref_id in (select distinct id from term_item where term_id=1 and item_id=$tag_id);"

	if [[ $VERBOSE = y ]] ; then
		echo $dbquery; echo ""
	fi
		#sub ids will be added to the end of the list - this way recursive isn't needed
		sqlite3 $database "$dbquery" >> "$ramdisk/ref_ids" 

	done < "$ramdisk/tag_ids"
	
	tag_ids="`cat $ramdisk/tag_ids`"
	category_search="and ref_id in (select ref_id from term_item where term_item.id in (`echo $tag_ids | sed 's/ /,/g'`))"

	dbquery="select distinct ref_id from term, item, term_item where term_item.term_id=term.id and term_item.item_id=item.id and ref_id in  (select distinct ref_id from term, item, term_item where term.name='$field_name' and item.text like '%$search_pattern%' and term_item.term_id=term.id and term_item.item_id=item.id) $category_search;"

	if [[ $VERBOSE = y ]] ; then
		echo $dbquery; echo ""
	fi
		else
			echo "category/tag couldn't be found"; echo ""
		fi
	done
	categories=`echo $categories | sed "s/^'',//g"`
fi

#if [[ -s "$ramdisk/tag_ids" ]] ; then
if [[ $categories = "''" ]] ; then
		dbquery="select distinct ref_id from term, item, term_item where term_item.term_id=term.id and term_item.item_id=item.id and ref_id in  (select distinct ref_id from term, item, term_item where term.name='$field_name' and item.text like '%$search_pattern%' and term_item.term_id=term.id and term_item.item_id=item.id);"
fi
###############################
# Items
###############################
person=$user
#person_id=`sqlite3 $database ...`
person_id=11

category_search=""
categories_clause=""

	sqlite3 "$database" "$dbquery" > "$ramdisk/ref_ids"
#result=`sqlite3 $database "$dbquery"`
#ref_id=`echo "$result" | head -n1 | cut -f4 -d'|'`
#			echo $result
#			ref_ids=`cat "$ramdisk/dboutput" | cut -f4 -d'|'` | sort -u $ramdisk/ref_ids

while true 
do
	while read ref_id
	do
		#check access
		dbquery="select distinct item_id from term, term_item where term_item.term_id=term.id and ref_id=$ref_id and term.name='view';"

		if [[ $VERBOSE = y ]] ; then
			echo $dbquery; echo ""
		fi
		#line=`sqlite3 $database "$dbquery"`
		sqlite3 $database "$dbquery" > "$ramdisk/viewer_ids"

		itemquery="select distinct term_item.id,term_id,term.name,item_id,item.text,ref_id from term, item, term_item where term_item.term_id=term.id and term_item.item_id=item.id and ref_id=$ref_id"
		if [[ $VERBOSE = y ]] ; then
			echo $itemquery; echo ""
		fi

		# if no access restrictions -> show it
		if [[ -s "$ramdisk/viewer_ids" ]] ; then
			echo ""
		else
			sqlite3 -header "$database" "$itemquery"; echo ""
		fi

		while read viewer_id
			  do
					#echo viewer_id = $viewer_id; echo ""
					#echo person_id = $person_id; echo ""
					if [[ $viewer_id = $person_id ]]; then
						# allowed to show results
						sqlite3 -header "$database" "$itemquery"; echo ""
						break
					fi
						#viewer_id could be a group
						#need to search for node
						dbquery="select distinct item_id from term, item, term_item where term_item.term_id=term.id and term_item.item_id=item.id and term.name='memberOf' and ref_id in (select distinct id from term_item where term_id=1 and item_id=$viewer_id);"
						sqlite3 $database "$dbquery" >> "$ramdisk/viewer_ids"
				done < "$ramdisk/viewer_ids"

				if [[ $VERBOSE = y ]] ; then
					echo $dbquery; echo ""
				fi

		echo ""

	done < $ramdisk/ref_ids
	
	read -n 1 -p "show new (r)ef_id or (t)erm_id? " choice
	echo ""
	if [[ $choice == "r" ]] ; then

		read -p "show id: " show_id #

		echo $show_id > "$ramdisk/ref_ids"


	elif [[ $choice == "t" ]] ; then

		read -p "show term_id: " term_id #
		dbquery="select distinct id from term_item where term_id=1 and item_id in (select item_id from ($itemquery and term_id=$term_id))"
		sqlite3 "$database" "$dbquery" > "$ramdisk/ref_ids"
	fi


	if [[ $VERBOSE = y ]] ; then
		echo $dbquery
	fi

done

exit $EXIT_SUCCESS

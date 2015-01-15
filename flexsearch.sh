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
while getopts 'bs:d:o:n:x:r:t:w:y:z:eiflgamopcvuqkh' OPTION ; do
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
		f)       #field_name 
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



j=0
# Verbrauchte Argumente überspringen
shift $(( OPTIND - 1 ))

# Eventuelle Tests auf min./max. Anzahl Argumente hier
if (( $# < 1 )) ; then
	echo ""
else
	# Kategorien auswählen
	for ARG ; do
		if [[ $VERBOSE = y ]] ; then
			echo -n "Argument: $ARG"
			echo ""
		fi
	done
fi




show_fields()  
{
		#	id=`echo "$line" | cut -f2 -d'|'`
			name=`echo "$line" | cut -f1 -d'|'`
			text=`echo "$line" | cut -f2 -d'|'`
			ref_id=`echo "$line" | cut -f3 -d'|'`
	#		date=`echo "$line" | cut -f5 -d'|' | sed "s/ 00:00:00//g"` #not necassary to show
	#		expiration=`echo "$line" | cut -f6 -d'|' | sed "s/ 23:59:59//g"` #not necassary to show
			
			if [[ $VERBOSE = y ]] ; then
			echo "line=$line"			
			echo "name=$name"
			echo "text=$text"
			echo "ref_id=$ref_id"
			fi
}


###############################
# Items
###############################
person=$user
name=$1
search=$2

#person_id=`sqlite3 $database ...`
person_id=11

dbquery="select distinct ref_id from term, item, term_item where term_item.term_id=term.id and term_item.item_id=item.id and ref_id in  (select distinct ref_id from term, item, term_item where term.name='$name' and item.text='$search' and term_item.term_id=term.id and term_item.item_id=item.id);"

if [[ $VERBOSE = y ]] ; then
	echo $dbquery; echo ""
fi
	sqlite3 "$database" "$dbquery" > "$ramdisk/ref_ids"
#result=`sqlite3 $database "$dbquery"`
#ref_id=`echo "$result" | head -n1 | cut -f4 -d'|'`
#			echo $result
#			ref_ids=`cat "$ramdisk/dboutput" | cut -f4 -d'|'` | sort -u $ramdisk/ref_ids

while true 
do

	while read ref_id
	do

		#Berechtigung prüfen
		dbquery="select distinct term_item.id,item_id,ref_id from term, term_item where term_item.term_id=term.id and ref_id=$ref_id and term.name='view';"

		if [[ $VERBOSE = y ]] ; then
			echo $dbquery; echo ""
		fi
		line=`sqlite3 $database "$dbquery"`

		itemquery="select distinct term_item.id,term.name,item.text,ref_id from term, item, term_item where term_item.term_id=term.id and term_item.item_id=item.id and ref_id=$ref_id;"


		if [[ $line = "" ]]; then  #wenn keine Zugriffsbeschränkung -> anzeigen
			sqlite3 "$database" "$itemquery"; echo ""
		else # alles darunter muss aufgelöst werden und pro Ebene überprüft
			#person_id in item_id?
			while [[ $line != "" ]]
			do
				item_id=`echo "$line" | cut -f2 -d'|'`
				#term_item_id=`echo "$line" | cut -f1 -d'|'`
				if [[ $item_id = $person_id ]]; then
					# allowed to show results
					sqlite3 "$database" "$itemquery"; echo ""
					break
				fi
				# item_id könnte group sein 
				# Referenz von NODE muss gesucht werden!
				dbquery="select distinct term_item.id,item_id,ref_id from term, item, term_item where term_item.term_id=term.id and term_item.item_id=item.id and term.name='memberOf' and ref_id in (select distinct id from term_item where term_id=1 and item_id=$item_id);"

				if [[ $VERBOSE = y ]] ; then
					echo $dbquery; echo ""
				fi
				line=`sqlite3 $database "$dbquery"`
				#echo $line
			done
		fi

		echo ""

	done < $ramdisk/ref_ids


	read -p "show id: " show_id #

	echo $show_id > "$ramdisk/ref_ids"

	if [[ $VERBOSE = y ]] ; then
		echo $dbquery
	fi

done

exit $EXIT_SUCCESS

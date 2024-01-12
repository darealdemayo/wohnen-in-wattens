#download calenders and rename entries according to TOP and Platform
mkdir dicercalsync > /dev/null
cd dicercalsync > /dev/null

wget -q https://www.airbnb.com/calendar/ical/581131839376406371.ics?s=ae58f0bea61a69dd68c5dada91df4a28 -O airbnb2.ics
sed 's/SUMMARY:Airbnb (Not available)/SUMMARY:Top 2 Airbnb.com/g' airbnb2.ics > top2a.ics
wget -q https://www.airbnb.com/calendar/ical/611306211360552307.ics?s=03cce35f7b965817f5d17d9cebb4fa01 -O airbnb3.ics
sed 's/SUMMARY:Airbnb (Not available)/SUMMARY:Top 3 Airbnb.com/g' airbnb3.ics > top3a.ics
wget -q https://www.airbnb.com/calendar/ical/566388004088529418.ics?s=d6e1c557fdacb30dbe3b2f84556e37bd -O airbnb5.ics
sed 's/SUMMARY:Airbnb (Not available)/SUMMARY:Top 5 Airbnb.com/g' airbnb5.ics > top5a.ics

wget -q https://ical.booking.com/v1/export?t=4d80d3c0-3f50-4b74-bbf7-9260fd064e4c -O booking2.ics
sed 's/SUMMARY:CLOSED - Not available/SUMMARY:Top2 Booking.com/g' booking2.ics > top2b.ics
wget -q https://ical.booking.com/v1/export?t=e18bddb2-323e-4ed6-90aa-8e391db4a565 -O booking3.ics
sed 's/SUMMARY:CLOSED - Not available/SUMMARY:Top3 Booking.com/g' booking3.ics > top3b.ics
wget -q https://ical.booking.com/v1/export?t=fa14efb1-8d93-42e5-950a-1ff55c66e70f -O booking5.ics
sed 's/SUMMARY:CLOSED - Not available/SUMMARY:Top5 Booking.com/g' booking5.ics > top5b.ics

wget -q https://ical.deskline.net/HAL/services/7bbffee4-8f00-4bd1-8b7a-7b621af0e4fb/d3ee812a-130c-44bd-b2af-31ff07fceb3b.ics -O tourismus2.ics
sed 's/SUMMARY:[^\n]*/SUMMARY:Top2 TVB Hall/g'  tourismus2.ics > top2t.ics
wget -q https://ical.deskline.net/HAL/services/3cdbfb92-ca5e-4e68-9259-45c5427ddda9/0cbddd0b-d602-4ec5-a203-1267d86148a6.ics -O tourismus3.ics
sed 's/SUMMARY:[^\n]*/SUMMARY:Top3 TVB Hall/g' tourismus3.ics > top3t.ics
wget -q https://ical.deskline.net/HAL/services/2582f0c5-948f-4f83-a679-4ee7ccfeaef9/de85228e-88ee-4066-854c-4a419d0a9634.ics -O tourismus5.ics
sed 's/SUMMARY:[^\n]*/SUMMARY:Top5 TVB Hall/g' tourismus5.ics > top5t.ics

# combine all calendar files

file=new.ics

echo "BEGIN:VCALENDAR" > $file
echo "CALSCALE:GREGORIAN" >> $file
echo "VERSION:2.0" >> $file
echo "METHOD:PUBLISH" >> $file

cat top*.ics | grep -v -e VCALENDAR -e VERSION -e PRODID -e CALSCALE -e METHOD -e DTSTAMP -e DESCRIPTION -e STATUS >> $file

echo "END:VCALENDAR" >> $file

#push ics to purelymail caldav

if diff "$file" "combined.ics" > /dev/null; then
	echo "no change"
	exit
else
	mv -f $file combined.ics
	curl -L \
	  -H "Accept: application/vnd.github+json" \
	  -H "Authorization: Bearer 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" \
	  -H "X-GitHub-Api-Version: 2022-11-28" \
	  https://api.github.com/repos/darealdemayo/wohnen-in-wattens/contents/calsync/combined.ics | grep sha | sed 's/sha//g' | sed 's/[^a-zA-Z0-9]//g' > shablob
	  
	curl -L \
	  -X PUT \
	  -H "Accept: application/vnd.github+json" \
	  -H "Authorization: Bearer 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" \
	  -H "X-GitHub-Api-Version: 2022-11-28" \
	  https://api.github.com/repos/darealdemayo/wohnen-in-wattens/contents/calsync/combined.ics \
	  -d '{"message":"CalSyncMerge AutoUpdate","committer":{"name":"DicerAutoupdater","email":"hausverwaltung@wohnen-in-wattens.at"},"content":"'$(base64 -w 0 combined.ics)'","sha":"'$(cat shablob)'"}'
	echo "^^^^^^^ change detected & ?github updated? check yourself ^^^^^^^"
 fi

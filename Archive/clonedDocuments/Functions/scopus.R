cat s14.csv | sed "1,8d" | sed 'N;$!P;$!D;$d' > s14_r.csv
cat s15.csv | sed "1,8d" | sed 'N;$!P;$!D;$d' > s15_r.csv
cat s16.csv | sed "1,8d" | sed 'N;$!P;$!D;$d' > s16_r.csv
cat s17.csv | sed "1,8d" | sed 'N;$!P;$!D;$d' > s17_r.csv
cat s18.csv | sed "1,8d" | sed 'N;$!P;$!D;$d' > s18_r.csv
cat s19.csv | sed "1,8d" | sed 'N;$!P;$!D;$d' > s19_r.csv
cat s20.csv | sed "1,8d" | sed 'N;$!P;$!D;$d' > s20_r.csv
cat s21.csv | sed "1,8d" | sed 'N;$!P;$!D;$d' > s21_r.csv









for i in *.csv; do
    sed -i "1,8d" -e 'N;$!P;$!D;$d' $i
done

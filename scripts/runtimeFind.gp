reset
set xlabel 'order'
set ylabel 'time(msec)'
set title 'perfomance comparison'
set term png enhanced font 'Verdana,10'
set output 'runtimeFind.png'
set format x "%10.0f"
set xtic 1200
set xtics rotate by 45 right

plot [:100][:]'cpy.txt' title 'cpy',\
         'ref.txt' title 'ref'





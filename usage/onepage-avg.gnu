# number of points in moving average
n = 30

# initialize the variables
do for [i=1:n] {
    eval(sprintf("back%d=0", i))
}

# build shift function (back_n = back_n-1, ..., back1=x)
shift = "("
do for [i=n:2:-1] {
    shift = sprintf("%sback%d = back%d, ", shift, i, i-1)
} 
shift = shift."back1 = x)"
# uncomment the next line for a check
# print shift

# build sum function (back1 + ... + backn)
sum = "(back1"
do for [i=2:n] {
    sum = sprintf("%s+back%d", sum, i)
}
sum = sum.")"
# uncomment the next line for a check
# print sum

# define the functions like in the gnuplot demo
# use macro expansion for turning the strings into real functions
samples(x) = $0 > (n-1) ? n : ($0+1)
avg_n(x) = (shift_n(x), @sum/samples($0))
shift_n(x) = @shift

# the final plot command looks quite simple
set terminal pngcairo enhanced font "Times New Roman,12.0" size 1280,960
set output "daily_average.png"
#set terminal post enhanced color solid background "white" size 1280,960
#set output "daily_average.eps"

set xdata time
set timefmt "%Y/%m/%d"
set yrange [0:]
set xrange ["2016/06/01":]
set format x "%b %Y"
set mxtics 86400
set xtics ( "2016/07/01", \
            "2017/01/01", "2017/07/01", \
            "2018/01/01", "2018/07/01", \
            "2019/01/01", "2019/07/01", \
            "2020/01/01", "2020/07/01", \
            "2021/01/01", "2021/07/01", \
            "2022/01/01" )
set format y "%.0s%c"
set xtics rotate by 90 offset 0,0 right 
set xtics font "Times Bold,16" 
set ytics font "Times Bold,18"
all=`zcat ../monitor/jobsa*.gz | wc -l`
thismonth=`cat ../monitor/jobs-0.csv | wc -l`
#set label print(all) at graph 0.5,0.5
sus=`awk '{s+=$2}END{print s}' daily.dat`
set label sprintf( "%.2fM jobs", (all+thismonth)/1e6 ) at graph 0.25,0.8 font "Times Bold,20"
set label sprintf( "%.2fM core-hours", sus/1e6 ) at graph 0.25,0.75 font "Times Bold,20"
#plot 'daily.dat' u 1:2 w l lw 4 lt 3 t '' smooth acsplines
#plot "daily.dat" using 1:2 w l notitle, \
# "daily.dat" using 1:(avg_n($2)) w l lc rgb "red" lw 3 title "avg\\_".n
plot "daily.dat" using 1:(avg_n($2)) w l lw 4 lt 3 lc rgb "blue" t ''

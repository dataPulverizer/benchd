import std.stdio: writeln;
import std.typecons: Tuple, tuple;
import std.algorithm.iteration: mean;
import std.datetime.stopwatch: AutoStart, StopWatch;

/*
  Simple function for doing benchmarking
  ulong n is the number of times the bench should be run for.
  string units is the time units for the StopWatch.
  ulong minN is minimum number of times the benchmark is run
        before the standard deviation is calculated.
  bool doPrint whether the results should be printed or not
*/
auto bench(alias fun, string units = "msecs", 
          ulong minN = 10, bool doPrint = false)(ulong n)
{
  auto times = new double[n];
  auto sw = StopWatch(AutoStart.no);
  for(ulong i = 0; i < n; ++i)
  {
    sw.start();
    fun();
    sw.stop();
    times[i] = cast(double)sw.peek.total!units;
    sw.reset();
  }
  double ave = mean(times);
  double sd = 0;
  /* Will only run summary stats if n > 5 */
  if(n >= minN)
  {
    for(ulong i = 0; i < n; ++i)
      sd += (times[i] - ave)^^2;
    sd /= (n - 1);
    sd ^^= 0.5;
  }else{
    sd = double.nan;
  }

  static if(doPrint)
    writeln("Mean time("~ units ~ "): ", ave, ", Standard Deviation: ", sd);
  
  return tuple!("mean", "sd")(ave, sd);
}

/* Example function to benchmarked */
void MyFun(T = double, ulong n = 100)()
{
  import std.random : Mt19937_64, unpredictableSeed, uniform01;
  Mt19937_64 gen;
  gen.seed(unpredictableSeed);
  auto arr = new T[n];
  for(ulong i = 0; i < n; ++i)
    arr[i] = uniform01!(T)(gen);
  return;
}

void main()
{
  auto b = bench!(MyFun!(double, 100_000))(100);
  writeln("Mean time(ms): ", b.mean, ", Standard Deviation: ", b.sd);
}

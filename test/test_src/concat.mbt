fn random(state: Double) -> Double {
    state * 75.0 + 74.0
};

fn modulo(x: Double, y: Double) -> Double {
    let q = x / y;
    x - q * y
};

fn concat(x: Array[Double], y: Array[Double], xlen: Int, ylen: Int) -> Array[Double] {
    let i = Array::make(1, 0);
    let result = Array::make(xlen + ylen, 0.0);
    fn aux() {
        if (i[0] == xlen + ylen) {
            result
        } else {
            // if i[0] < xlen
            let _ = if not(xlen <= i[0]) {
                result[i[0]] = x[i[0]];
                ()
            } else {
                result[i[0]] = y[i[0] - xlen];
                ()
            };
            i[0] = i[0] + 1;
            aux()
        }
    };
    aux()
};

fn print_array(arr: Array[Double], n: Int) -> Unit {
    fn aux(i: Int) -> Unit {
        if i == n {
            ()
        } else {
            let _ = print_int(truncate(arr[i]));
            let _ = print_char(32);
            aux(i + 1)
        }
    };
    aux(0)
};

fn main {
    let a = Array::make(10, 0.0);
    let b = Array::make(10, 0.0);
    fn fill(i) {
        if not(10 <= i) {
            a[i] = float_of_int(i);
            b[i] = 9.0 - float_of_int(i);
            fill(i + 1)
        } else {
            ()
        }
    };
    let _ = fill(0);
    print_array(concat(a, b, 10, 10), 20)
};
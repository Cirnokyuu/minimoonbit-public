pub fn Knf::to_json(self : Knf) -> Json {
  match self {
    Unit => ["Unit"]
    Int(i) => ["Int", Number(i.to_double())]
    Double(d) => ["Double", Number(d)]
    Neg(n) => ["Neg", n.to_json()]
    BNeg(n) => ["BNeg", n.to_json()]
    Add(n1, n2) => ["Add", n1.to_json(), n2.to_json()]
    Sub(n1, n2) => ["Sub", n1.to_json(), n2.to_json()]
    Mul(n1, n2) => ["Mul", n1.to_json(), n2.to_json()]
    Div(n1, n2) => ["Div", n1.to_json(), n2.to_json()]
    Le(n1, n2) => ["Le", n1.to_json(), n2.to_json()]
    Eq(n1, n2) => ["Eq", n1.to_json(), n2.to_json()]
    FNeg(n) => ["FNeg", n.to_json()]
    FAdd(n1, n2) => ["FAdd", n1.to_json(), n2.to_json()]
    FSub(n1, n2) => ["FSub", n1.to_json(), n2.to_json()]
    FMul(n1, n2) => ["FMul", n1.to_json(), n2.to_json()]
    FDiv(n1, n2) => ["FDiv", n1.to_json(), n2.to_json()]
    IfEq(n1, n2, k1, k2) =>
      ["IfEq", n1.to_json(), n2.to_json(), k1.to_json(), k2.to_json()]
    IfLe(n1, n2, k1, k2) =>
      ["IfLe", n1.to_json(), n2.to_json(), k1.to_json(), k2.to_json()]
    Let(n, k1, k2) =>
      ["Let", n.to_json(), k1.to_json(), k2.to_json()]
    Var(n) => ["Var", n.to_json()]
    LetRec(f, k) => ["LetRec", f.to_json(), k.to_json()]
    Apply(n, ns) | CallTailRec(n, ns) => ["Apply", n.to_json(), ns.to_json()]
    Tuple(ns) => ["Tuple", ns.to_json()]
    LetTuple(n_ts, n, k) => {
      let n_ts_res = []
      for it in n_ts {
        n_ts_res.push([it.to_json()])
      }
      ["LetTuple", n_ts_res.to_json(), n.to_json(), k.to_json()]
    }
    Get(n1, n2) => ["Get", n1.to_json(), n2.to_json()]
    Put(n1, n2, n3) => ["Put", n1.to_json(), n2.to_json(), n3.to_json()]
    ExternalFunctionApplication(s, ns) =>
      ["ExternalFunctionApplication", s.to_json(), ns.to_json()]
  }
}

pub fn FuncDef::to_json(self : FuncDef) -> Json {
  {
    "name": self.name.to_json(),
    "ty": self.ty.to_json(),
    "args": self.args.to_json(),
    "body": self.body.to_json(),
  }
}

pub fn Knf::from_json(json : Json) -> Knf! {
  match json {
    ["Unit"] => Unit
    ["Int", Number(i)] => Int(i.to_int())
    ["Double", Number(d)] => Double(d)
    ["Neg", n] => Neg(Name::from_json!(n))
    ["Add", n1, n2] => Add(Name::from_json!(n1), Name::from_json!(n2))
    ["Sub", n1, n2] => Sub(Name::from_json!(n1), Name::from_json!(n2))
    ["Mul", n1, n2] => Mul(Name::from_json!(n1), Name::from_json!(n2))
    ["Div", n1, n2] => Div(Name::from_json!(n1), Name::from_json!(n2))
    ["FNeg", n] => FNeg(Name::from_json!(n))
    ["FAdd", n1, n2] => FAdd(Name::from_json!(n1), Name::from_json!(n2))
    ["FSub", n1, n2] => FSub(Name::from_json!(n1), Name::from_json!(n2))
    ["FMul", n1, n2] => FMul(Name::from_json!(n1), Name::from_json!(n2))
    ["FDiv", n1, n2] => FDiv(Name::from_json!(n1), Name::from_json!(n2))
    ["IfEq", n1, n2, k1, k2] =>
      IfEq(
        Name::from_json!(n1),
        Name::from_json!(n2),
        Knf::from_json!(k1),
        Knf::from_json!(k2),
      )
    ["IfLe", n1, n2, k1, k2] =>
      IfLe(
        Name::from_json!(n1),
        Name::from_json!(n2),
        Knf::from_json!(k1),
        Knf::from_json!(k2),
      )
    ["Let", n, k1, k2] =>
      Let(
        Name::from_json!(n),
        Knf::from_json!(k1),
        Knf::from_json!(k2),
      )
    ["Var", n] => Var(Name::from_json!(n))
    ["LetRec", f, k] => LetRec(FuncDef::from_json!(f), Knf::from_json!(k))
    ["Apply", n, Array(ns)] => {
      let rns = []
      for it in ns {
        rns.push(Name::from_json!(it))
      }
      Apply(Name::from_json!(n), rns)
    }
    ["LetTuple", Array(n_ts), n, k] => {
      let n_ts_res = []
      for it in n_ts {
        match it {
          n => n_ts_res.push(Name::from_json!(n))
        }
      }
      LetTuple(n_ts_res, Name::from_json!(n), Knf::from_json!(k))
    }
    ["Get", n1, n2] => Get(Name::from_json!(n1), Name::from_json!(n2))
    ["Put", n1, n2, n3] =>
      Put(Name::from_json!(n1), Name::from_json!(n2), Name::from_json!(n3))
    ["ExternalFunctionApplication", String(s), Array(ns)] => {
      let rns = []
      for it in ns {
        rns.push(Name::from_json!(it))
      }
      ExternalFunctionApplication(s, rns)
    }
    _ => fail!("Knf::from_json: invalid json: \{json}")
  }
}

pub fn FuncDef::from_json(json : Json) -> FuncDef! {
  match json {
    { "name": n, "ty": t, "args": Array(args), "body": k } => {
      let rargs = []
      for it in args {
        match it {
          n => rargs.push(Name::from_json!(n))
        }
      }
      {
        name: Name::from_json!(n),
        ty: Type::from_json!(t),
        args: rargs,
        body: Knf::from_json!(k),
      }
    }
    _ => fail!("FuncDef::from_json: invalid json: \{json}")
  }
}

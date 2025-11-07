abstract class BankAcc {
  final String _accNo;
  final String _holder;
  double bal;
  final List<String> _transactions = [];

  BankAcc(this._accNo, this._holder, this.bal) {
    record('Account created with initial balance: \$$bal');
  }

  String get accNo => _accNo;
  String get holder => _holder;

  void record(String msg) {
    _transactions.add('[${DateTime.now()}] $msg');
  }

  void showHistory() {
    print('Transaction History for $_accNo ($_holder):');
    if (_transactions.isEmpty) {
      print('No transactions yet.');
    } else {
      for (var t in _transactions) {
        print(t);
      }
    }
    print('--------------------------------------');
  }

  bool deposit(double amt);
  bool withdraw(double amt);
  void calcInterest() {}

  void showInfo() {
    print('Account No: $_accNo');
    print('Holder: $_holder');
    print('Balance: \$$bal');
    print('--------------------------------------');
  }
}

// Interface for accounts that earn interest
mixin InterestBearing {
  void calcInterest();
  void calculate() => calcInterest();
}

// Savings Account
class SavAcc extends BankAcc with InterestBearing {
  static const double _minBal = 500.0;
  static const double _intRate = 0.02;
  static const int _wdLimit = 3;
  int _wdCount = 0;

  SavAcc(super.accNo, super.holder, super.bal);

  @override
  bool deposit(double amt) {
    if (amt <= 0) {
      print('Invalid deposit amount.');
      return false;
    }
    bal += amt;
    record('Deposited \$$amt to Savings Account. New balance: \$$bal');
    print('Deposited \$$amt to Savings Account.');
    return true;
  }

  @override
  bool withdraw(double amt) {
    if (amt <= 0) {
      print('Invalid withdrawal amount.');
      return false;
    }
    if (_wdCount >= _wdLimit) {
      print('Withdrawal limit reached.');
      record('Failed withdrawal: limit reached.');
      return false;
    }
    if (bal - amt < _minBal) {
      print('Cannot withdraw. Minimum balance requirement not met.');
      record('Failed withdrawal: below minimum balance.');
      return false;
    }
    bal -= amt;
    _wdCount++;
    record('Withdrew \$$amt from Savings Account. New balance: \$$bal');
    print('Withdrew \$$amt from Savings Account.');
    return true;
  }

  @override
  void calcInterest() {
    double interest = bal * _intRate;
    bal += interest;
    record('Interest added: \$$interest at rate ${_intRate * 100}%.');
    print('Interest of \$$interest added to Savings Account.');
  }
}

// Checking Account
class ChkAcc extends BankAcc {
  static const double _fee = 35.0;

  ChkAcc(super.accNo, super.holder, super.bal);

  @override
  bool deposit(double amt) {
    if (amt <= 0) {
      print('Invalid deposit amount.');
      return false;
    }
    bal += amt;
    record('Deposited \$$amt to Checking Account. New balance: \$$bal');
    print('Deposited \$$amt to Checking Account.');
    return true;
  }

  @override
  bool withdraw(double amt) {
    if (amt <= 0) {
      print('Invalid withdrawal amount.');
      return false;
    }
    bal -= amt;
    record('Withdrew \$$amt from Checking Account. New balance: \$$bal');
    if (bal < 0) {
      bal -= _fee;
      record('Overdraft! Fee of \$_fee applied.');
      print('Overdraft! Fee of \$_fee applied.');
    }
    print('Withdrew \$$amt from Checking Account.');
    return true;
  }
}

// Premium Account
class PremAcc extends BankAcc with InterestBearing {
  static const double _minBal = 10000.0;
  static const double _intRate = 0.05;

  PremAcc(super.accNo, super.holder, super.bal);

  @override
  bool deposit(double amt) {
    if (amt <= 0) {
      print('Invalid deposit amount.');
      return false;
    }
    bal += amt;
    record('Deposited \$$amt to Premium Account. New balance: \$$bal');
    print('Deposited \$$amt to Premium Account.');
    return true;
  }

  @override
  bool withdraw(double amt) {
    if (amt <= 0) {
      print('Invalid withdrawal amount.');
      return false;
    }
    if (bal - amt < _minBal) {
      print('Cannot withdraw. Must maintain minimum balance of \$_minBal.');
      record('Failed withdrawal: below minimum balance.');
      return false;
    }
    bal -= amt;
    record('Withdrew \$$amt from Premium Account. New balance: \$$bal');
    print('Withdrew \$$amt from Premium Account.');
    return true;
  }

  @override
  void calcInterest() {
    double interest = bal * _intRate;
    bal += interest;
    record('Interest added: \$$interest at rate ${_intRate * 100}%.');
    print('Interest of \$$interest added to Premium Account.');
  }
}

// Student Account
class StuAcc extends BankAcc {
  static const double _maxBal = 5000.0;

  StuAcc(super.accNo, super.holder, super.bal);

  @override
  bool deposit(double amt) {
    if (amt <= 0) {
      print('Invalid deposit amount.');
      return false;
    }
    if (bal + amt > _maxBal) {
      print('Cannot deposit. Max balance of \$_maxBal exceeded.');
      record('Failed deposit: exceeded max balance.');
      return false;
    }
    bal += amt;
    record('Deposited \$$amt to Student Account. New balance: \$$bal');
    print('Deposited \$$amt to Student Account.');
    return true;
  }

  @override
  bool withdraw(double amt) {
    if (amt <= 0) {
      print('Invalid withdrawal amount.');
      return false;
    }
    if (amt > bal) {
      print('Cannot withdraw. Insufficient funds.');
      record('Failed withdrawal: insufficient funds.');
      return false;
    }
    bal -= amt;
    record('Withdrew \$$amt from Student Account. New balance: \$$bal');
    print('Withdrew \$$amt from Student Account.');
    return true;
  }
}

// Bank Class managing all accounts
class Bank {
  final Map<String, BankAcc> _accs = {};

  void create(BankAcc acc) {
    if (_accs.containsKey(acc.accNo)) {
      print('Account with number ${acc.accNo} already exists.');
      return;
    }
    _accs[acc.accNo] = acc;
    print('Account created: ${acc.accNo}');
  }

  BankAcc? find(String accNo) => _accs[accNo];

  void transfer(String from, String to, double amt) {
    var src = find(from);
    var dst = find(to);

    if (src == null || dst == null) {
      print('One or both accounts not found.');
      return;
    }

    bool success = src.withdraw(amt);
    if (success) {
      dst.deposit(amt);
      src.record('Transferred \$$amt to account $to');
      dst.record('Received \$$amt from account $from');
      print('Transfer of \$$amt from $from to $to completed.');
    } else {
      print('Transfer failed.');
    }
  }

  void report() {
    print('\nBank Accounts Report:');
    _accs.forEach((no, acc) {
      acc.showInfo();
    });
  }

  void applyInterest() {
    print('\nApplying Monthly Interest...');
    _accs.forEach((no, acc) {
      if (acc is InterestBearing) {
        acc.calcInterest();
      }
    });
  }
}

void main() {
  var bank = Bank();

  var sav = SavAcc('S123', 'Sujal', 1000.0);
  var chk = ChkAcc('A923', 'Aayush', 500.0);
  var prem = PremAcc('P456', 'Ankit', 15000.0);
  var stu = StuAcc('ST423', 'Probs', 2000.0);

  bank.create(sav);
  bank.create(chk);
  bank.create(prem);
  bank.create(stu);

  bank.report();
  bank.applyInterest();
  bank.transfer('S123', 'P456', 200.0);

  sav.showHistory();
  prem.showHistory();
}

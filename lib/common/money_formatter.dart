import 'package:flutter_money_formatter/flutter_money_formatter.dart';

String currencyFormatWithSymbol(double amt) {
  FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
    amount: amt,
    settings: MoneyFormatterSettings(
        symbol: '₹',
        thousandSeparator: ',',
        symbolAndNumberSeparator: ' ',
        fractionDigits: 0,
        compactFormatType: CompactFormatType.short
    )
  );
  return fmf.output.symbolOnLeft;
}

String currencyFormatWithoutSymbol(double amt) {
  FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
    amount: amt,
    settings: MoneyFormatterSettings(
        thousandSeparator: ',',
        symbolAndNumberSeparator: ' ',
        fractionDigits: 0,
        compactFormatType: CompactFormatType.short
    )
  );
  return fmf.output.nonSymbol;
}

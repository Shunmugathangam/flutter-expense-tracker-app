abstract class ChartEvent { }

class OnChartExpenseDataLoadEvent extends ChartEvent {
  final Map<String, double> lst;
  OnChartExpenseDataLoadEvent(this.lst);
}

class OnChartBudgetDataLoadEvent extends ChartEvent {
  final Map<String, double> lst;
  OnChartBudgetDataLoadEvent(this.lst);
}


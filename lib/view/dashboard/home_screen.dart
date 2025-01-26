import 'package:diabetes_tracking/codefusionbit.dart';
import 'package:intl/intl.dart';

class HomeScreen extends GetView<GlucoseController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: Text('Diabetes Tracker'),
        actions: [
          IconButton(
            icon: Obx(() => Icon(Get.find<ThemeController>().isDarkMode
                ? Icons.dark_mode
                : Icons.light_mode)),
            onPressed: () => Get.find<ThemeController>().toggleTheme(),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: 'Confirm Logout',
                middleText: 'Are you sure you want to log out?',
                textConfirm: 'Yes',
                textCancel: 'No',
                backgroundColor: Theme.of(context).colorScheme.secondary,
                confirmTextColor:
                Theme.of(context).textTheme.titleMedium?.color,
                cancelTextColor: Theme.of(context).textTheme.titleMedium?.color,
                buttonColor: Theme.of(context).colorScheme.errorContainer,
                onConfirm: () async {
                  Get.find<AuthController>().signOut();
                },
                onCancel: () {
                  Get.back(); // Close the dialog without deleting
                },
              );
            },
          ),
        ],
      ),
      body: Obx(
            () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: controller.readings.isEmpty  || controller.lastReading.value == null ? AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Text('Add your first reading'),
            ),
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodayCard(context),
              SizedBox(height: 20),
              _buildChartCard(context),
              SizedBox(height: 20),
              _buildReadingList(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddFoodDialog(context),
                  icon: Icon(Icons.restaurant),
                  label: Text('Add Food'),
                  style: ElevatedButton.styleFrom(
                    //backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddReadingDialog(context),
                  icon: Icon(Icons.add),
                  label: Text('Add Reading'),
                  style: ElevatedButton.styleFrom(
                    //backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Obx(() {
          final reading = controller.lastReading.value;
          // Format the DateTime
          String formattedDate = DateFormat('MMMM dd, yyyy')
              .format(reading?.date ?? DateTime.now());
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildValueBox(
                      'Fasting',
                      reading?.fastingValue?.toString() ?? '--',
                      reading?.fastingValue ?? 0,
                      reading?.fastingDate ?? reading!.date,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildValueBox(
                      'Non-Fasting',
                      reading?.nonFastingValue?.toString() ?? '--',
                      reading?.nonFastingValue ?? 0,
                      reading?.nonFastingDate ?? reading!.date,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildValueBox(String title, String value, num numValue, DateTime date) {
    Color getColorForGlucose(double value) {
      if (title == 'Fasting') {
        if (value < 70) return Colors.red; // Low
        if (value <= 100) return Colors.green; // Normal
        if (value <= 125) return Colors.orange; // Pre-diabetic
        return Colors.red; // Diabetic
      } else {
        // Non-Fasting
        if (value < 70) return Colors.red; // Low
        if (value <= 140) return Colors.green; // Normal
        if (value <= 199) return Colors.orange; // Pre-diabetic
        return Colors.red; // Diabetic
      }
    }

    Color color =
    value == '--' ? Colors.grey : getColorForGlucose(double.parse(value));
    String formattedDate = DateFormat('hh:mm a')
        .format(date);
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '$value mg/dL',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value != '--' ? formattedDate : '--',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildFilterChips(context),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Obx(() {
                final readings = _getFilteredReadings();
                if (readings.isEmpty) {
                  return Center(child: Text('No readings available'));
                }

                final fastingSpots = <FlSpot>[];
                final nonFastingSpots = <FlSpot>[];

                for (var reading in readings) {
                  if (reading.fastingValue != null) {
                    fastingSpots.add(FlSpot(
                      (reading.fastingDate ?? reading.date).millisecondsSinceEpoch.toDouble(),
                      reading.fastingValue!.toDouble(),
                    ));
                  }
                  if (reading.nonFastingValue != null) {
                    nonFastingSpots.add(FlSpot(
                      (reading.nonFastingDate ?? reading.date).millisecondsSinceEpoch.toDouble(),
                      reading.nonFastingValue!.toDouble(),
                    ));
                  }
                }

                if (fastingSpots.isEmpty && nonFastingSpots.isEmpty) {
                  return Center(child: Text('No data to display'));
                }

                final allSpots = [...fastingSpots, ...nonFastingSpots];
                final allDates = allSpots.map((spot) => spot.x).toList();
                final allValues = allSpots.map((spot) => spot.y).toList();

                final minDate = allDates.reduce((a, b) => a < b ? a : b);
                final maxDate = allDates.reduce((a, b) => a > b ? a : b);
                final maxValue = allValues.reduce((a, b) => a > b ? a : b);

                // Calculate if scrolling needed
                bool needsScroll = false;
                if (controller.selectedFilter.value != '1M' &&
                    controller.selectedFilter.value != '3M') {
                  needsScroll =
                      maxDate - minDate > Duration(days: 60).inMilliseconds;
                }

                Widget chart = LineChart(
                  LineChartData(
                    backgroundColor: Theme.of(context).cardColor,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 50,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 86400000 * 10,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            return Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MM/dd').format(date),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 50,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    minX: minDate,
                    maxX: maxDate,
                    minY: 0,
                    maxY: (maxValue.ceil() / 50).ceil() * 50.0,
                    lineBarsData: [
                      LineChartBarData(
                        spots: fastingSpots,
                        isCurved: false,
                        color: Colors.blue,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.blue,
                              strokeWidth: 1,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      ),
                      LineChartBarData(
                        spots: nonFastingSpots,
                        isCurved: false,
                        color: Colors.red,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.red,
                              strokeWidth: 1,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        //tooltipBgColor: Theme.of(context).cardColor,
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                spot.x.toInt());
                            return LineTooltipItem(
                              '${DateFormat('dd MMM, yyyy hh:mm a').format(date)}\n${spot.y.toStringAsFixed(1)} mg/dL',
                              TextStyle(
                                color: spot.bar.color,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                );

                return needsScroll
                    ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: max(
                      MediaQuery.of(context).size.width - 64,
                      (maxDate - minDate) / 86400000 * 50,
                    ),
                    child: chart,
                  ),
                )
                    : chart;
              }),
            ),
            // Legend
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Fasting', Colors.blue),
                  SizedBox(width: 24),
                  _buildLegendItem('Non-Fasting', Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: controller.selectedFilter.value,
        isDense: true,
        items: ['1M', '3M', '6M', '1Y', 'ALL'].map((filter) {
          String label = filter == 'ALL'
              ? 'All Time'
              : filter == '1Y'
              ? '1 Year'
              : filter == '6M'
              ? '6 Months'
              : filter == '3M'
              ? '3 Months'
              : '1 Month';

          return DropdownMenuItem(
            value: filter,
            child: Text(label),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.selectedFilter.value = value;
          }
        },
        dropdownColor: Theme.of(context).cardColor,
        icon: Icon(Icons.keyboard_arrow_down),
        borderRadius: BorderRadius.circular(8),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  List<DailyReading> _getFilteredReadings() {
    final now = DateTime.now();
    final readings = controller.readings;

    switch (controller.selectedFilter.value) {
      case '1M':
        return readings
            .where((r) => r.date.isAfter(now.subtract(Duration(days: 30))))
            .toList();
      case '3M':
        return readings
            .where((r) => r.date.isAfter(now.subtract(Duration(days: 90))))
            .toList();
      case '6M':
        return readings
            .where((r) => r.date.isAfter(now.subtract(Duration(days: 180))))
            .toList();
      case '1Y':
        return readings
            .where((r) => r.date.isAfter(now.subtract(Duration(days: 365))))
            .toList();
      default:
        return readings;
    }
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildReadingList(BuildContext context) {
    return Obx(() {
      final allReadings = controller.readings;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'All Readings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (allReadings.isNotEmpty &&
                  (allReadings.length > (Get.width < 600 ? 1 : 2)))
                Text(
                  'Scroll Right',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          if (allReadings.isEmpty)
            Center(
              child: Text(
                'No Readings',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            HorizontalListView.builder(
              crossAxisCount:
              Get.width < 600 ? 1 : 2, // Number of items displayed per row.
              crossAxisSpacing: 16, // Spacing between items in the same row.
              alignment: CrossAxisAlignment
                  .start, // Alignment of items within the row (default is center)
              controller:
              HorizontalListViewController(), // Optional scroll controller.
              itemCount:
              allReadings.length, // Total number of items in the list.
              itemBuilder: (BuildContext context, int index) {
                final readings = allReadings[index];
                final foodRecords = readings.foodRecords;
                String formattedDate =
                DateFormat('MMMM dd, yyyy').format(readings.date);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    formattedDate,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      if (readings.id != null &&
                                          !(Get.isDialogOpen ?? false)) {
                                        await Get.defaultDialog(
                                          title: 'Confirm Delete',
                                          middleText:
                                          'Are you sure you want to delete this daily reading?',
                                          textConfirm: 'Yes',
                                          textCancel: 'No',
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          confirmTextColor: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.color,
                                          cancelTextColor: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.color,
                                          buttonColor: Theme.of(context)
                                              .colorScheme
                                              .errorContainer,
                                          onConfirm: () {
                                            Get.back(); // Close dialog
                                            controller.deleteDailyReading(
                                                readings.id!);
                                          },
                                          onCancel: () {
                                            Get.back(); // Close dialog without deleting
                                          },
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red))
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildValueBox(
                                    'Fasting',
                                    readings.fastingValue?.toString() ?? '--',
                                    readings.fastingValue ?? 0,
                                    readings.fastingDate ?? readings.date,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildValueBox(
                                    'Non-Fasting',
                                    readings.nonFastingValue?.toString() ??
                                        '--',
                                    readings.nonFastingValue ?? 0,
                                    readings.nonFastingDate ?? readings.date,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: foodRecords.length,
                          itemBuilder: (context, index) {
                            final food = foodRecords[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              elevation: 5,
                              shadowColor: Colors.grey.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.restaurant),
                                ),
                                title: Text(food.food),
                                subtitle: Text(
                                  '${food.meal.capitalizeFirst}',
                                ),
                                trailing: PopupMenuButton(
                                  icon: Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Edit'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onTap: () => _showEditFoodDialog(
                                          context, food, readings),
                                    ),
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.delete,
                                            color: Colors.red),
                                        title: Text('Delete',
                                            style:
                                            TextStyle(color: Colors.red)),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onTap: () {
                                        if (readings.id != null) {
                                          controller.deleteFoodRecord(
                                              readings.id!, food);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
        ],
      );
    });
  }

  void _showAddReadingDialog(BuildContext context) {
    final valueController = TextEditingController();
    final isFasting = true.obs;
    final selectedDate = DateTime.now().obs;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Reading',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                  )
                ],
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text('Date'),
                  subtitle: Obx(() => Text(
                      '${DateFormat('MMMM dd, yyyy').format(selectedDate.value)} ${DateFormat('hh:mm a').format(selectedDate.value)}')),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {

                      if(!context.mounted){
                        return;
                      }
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate.value),
                      );
                      if (time != null) {
                        selectedDate.value = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      }
                    }
                  },
                  trailing: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Blood Glucose Level (mg/dL)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Obx(() => SwitchListTile(
                title: Text('Fasting Reading'),
                value: isFasting.value,
                onChanged: (value) => isFasting.value = value,
              )),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final value = double.tryParse(valueController.text);
                    if (value != null) {
                      controller.updateReading(
                        date: selectedDate.value,
                        fastingValue: isFasting.value ? value : null,
                        fastingDate:
                        isFasting.value ? selectedDate.value : null,
                        nonFastingValue: !isFasting.value ? value : null,
                        nonFastingDate:
                        !isFasting.value ? selectedDate.value : null,
                      );
                      Get.back();
                    }
                  },
                  child: Text('Save Reading'),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddFoodDialog(BuildContext context) {
    final foodController = TextEditingController();
    final selectedMeal = 'breakfast'.obs;
    final selectedDate = DateTime.now().obs;
    final meals = ['breakfast', 'lunch', 'dinner', 'snack'];

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Food',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                  )
                ],
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text('Date'),
                  subtitle: Obx(() => Text(
                      DateFormat('MMMM dd, yyyy').format(selectedDate.value))),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) selectedDate.value = date;
                  },
                  trailing: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: foodController,
                decoration: InputDecoration(
                  labelText: 'Food Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                value: selectedMeal.value,
                decoration: InputDecoration(
                  labelText: 'Meal Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: meals
                    .map((meal) => DropdownMenuItem(
                  value: meal,
                  child: Text(meal.capitalize!),
                ))
                    .toList(),
                onChanged: (value) => selectedMeal.value = value!,
              )),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (foodController.text.isNotEmpty) {
                      final newRecord = FoodRecord(
                        food: foodController.text,
                        meal: selectedMeal.value,
                        createdAt: selectedDate.value,
                      );
                      controller.addFoodRecord(selectedDate.value, newRecord);
                      Get.back();
                    }
                  },
                  child: Text('Save Food'),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showEditFoodDialog(
      BuildContext context, FoodRecord food, DailyReading reading) {
    final foodController = TextEditingController(text: food.food);
    final selectedMeal = food.meal.obs;
    final meals = ['breakfast', 'lunch', 'dinner', 'snack'];

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Food',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                  )
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: foodController,
                decoration: InputDecoration(
                  labelText: 'Food Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                value: selectedMeal.value,
                decoration: InputDecoration(
                  labelText: 'Meal Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: meals
                    .map((meal) => DropdownMenuItem(
                  value: meal,
                  child: Text(meal.capitalize!),
                ))
                    .toList(),
                onChanged: (value) => selectedMeal.value = value!,
              )),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (foodController.text.isNotEmpty) {
                      final updatedRecord = FoodRecord(
                        food: foodController.text,
                        meal: selectedMeal.value,
                        createdAt: food.createdAt,
                      );
                      controller.updateFoodRecord(
                        reading.id!,
                        food,
                        updatedRecord,
                      );
                      Get.back();
                    }
                  },
                  child: Text('Update Food'),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;
import '../controller/admin_dashboard_controller.dart';
import '../models/admin_dashboard_response.dart';
import '../newhome/maindashboard/admin_dashboard.dart';
import '../utilities/baseutitiles.dart';

class POVsBillListViewAll extends StatefulWidget {

  const POVsBillListViewAll({Key? key})
      : super(key: key);

  @override
  State<POVsBillListViewAll> createState() => _POVsBillListViewAllState();
}

class _POVsBillListViewAllState extends State<POVsBillListViewAll> {
  AdminDashboardController adminDashboardController =
      Get.put(AdminDashboardController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        adminDashboardController.poVsBillTableList
            .assignAll(adminDashboardController.allPoVsBillTableList);
        searchController.clear();
        adminDashboardController.selectedStatus.value = "All Status";
        return true;
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "PO Value vs Billed Amount",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false, // Hide left back button
            actions: [
              TextButton(
                  onPressed: () {
                    adminDashboardController.poVsBillTableList.assignAll(
                        adminDashboardController.allPoVsBillTableList);
                    searchController.clear();
                    adminDashboardController.selectedStatus.value =
                        "All Status";
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Back",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ))
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        width: 150,
                        child: TextField(
                            controller: searchController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: "Search",
                              hintStyle: TextStyle(fontSize: 14),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey, // Purple when focused
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              adminDashboardController
                                  .filterPoVsBillValues(value);
                            }),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Obx(() => SizedBox(
                          width: 180,
                          height: 42,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              alignment: Alignment.centerLeft,
                              hint: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "All",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              items: adminDashboardController.poVsBillStatusList
                                  .map((status) => DropdownMenuItem<String>(
                                        value: status,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            status,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              value:
                                  adminDashboardController.selectedStatus.value,
                              onChanged: (value) {
                                adminDashboardController.selectedStatus.value =
                                    value!;
                                adminDashboardController.filterProjects();
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 42,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 22,
                                iconEnabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 220,
                                offset: const Offset(0, 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Obx(() => ListView.separated(
                      padding: EdgeInsets.all(12),
                      shrinkWrap: true,
                      itemCount:
                          adminDashboardController.poVsBillTableList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item =
                            adminDashboardController.poVsBillTableList[index];
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 44,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.projectName!
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blueGrey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.projectName!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "PO: ${item.poValue!}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        item.varianceLabel!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: adminDashboardController
                                              .getVarianceColor(
                                                  item.varianceLabel),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              SegmentedProgressBar(
                                progress: adminDashboardController
                                    .getProgress(item.billingPercent),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Bill: ₹${item.billValue!}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${item.billingPercent!} of PO",
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BOQProgressViewAll extends StatefulWidget {

  const BOQProgressViewAll({Key? key}) : super(key: key);

  @override
  State<BOQProgressViewAll> createState() => _BOQProgressViewAllState();
}

class _BOQProgressViewAllState extends State<BOQProgressViewAll> {
  AdminDashboardController adminDashboardController =
      Get.put(AdminDashboardController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        adminDashboardController.boqProgressTableList
            .assignAll(adminDashboardController.allBoqProgressTableList);
        searchController.clear();
        adminDashboardController.selectedStatus.value = "All Status";
        return true;
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "All Projects",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false, // Hide left back button
            actions: [
              TextButton(
                  onPressed: () {
                    adminDashboardController.boqProgressTableList.assignAll(
                        adminDashboardController.allBoqProgressTableList);
                    searchController.clear();
                    adminDashboardController.selectedStatus.value =
                        "All Status";
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Back",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ))
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        width: 150,
                        child: TextField(
                            controller: searchController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: "Search",
                              hintStyle: TextStyle(fontSize: 14),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey, // Purple when focused
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              adminDashboardController
                                  .filterBOQProgressValues(value);
                            }),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Obx(() => SizedBox(
                          width: 180,
                          height: 42,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              alignment: Alignment.centerLeft,
                              hint: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "All",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              items: adminDashboardController.boqProgressStatusList
                                  .map((status) => DropdownMenuItem<String>(
                                        value: status,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            status,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              value:
                                  adminDashboardController.selectedStatus.value,
                              onChanged: (value) {
                                adminDashboardController.selectedStatus.value =
                                    value!;
                                adminDashboardController.filterBOQProgressProjects();
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 42,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 22,
                                iconEnabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 220,
                                offset: const Offset(0, 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Obx(() => ListView.separated(
                      padding: EdgeInsets.all(12),
                      shrinkWrap: true,
                      itemCount:
                          adminDashboardController.boqProgressTableList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item =
                            adminDashboardController.boqProgressTableList[index];
                        final statusColor = adminDashboardController.getStatusColor(item.status);
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child:  Column(
                            children: [
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 44,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.projectName!
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.projectName!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                "Start: ${item.startDate ?? "-"}",
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            item.status!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(flex: 1,
                                    child: Text(
                                      "BOQ: ₹${BaseUtitiles().formatAmount(item.boqValue.toString())}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(flex: 1,
                                    child: Text(
                                      "Planned % : ${BaseUtitiles().formatAmount(item.plannedPercentage.toString())}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(flex: 1,
                                    child: Text(
                                      "Actual % : ${BaseUtitiles().formatAmount(item.actualPercentage.toString())}",
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  segmentedProgress(
                                    progress: item.progress!,
                                    color: adminDashboardController.getStatusColor(item.status).withOpacity(0.8),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      Text(
                                        item.progress!,
                                        style: TextStyle(
                                          color: adminDashboardController.getStatusColor(item.status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      Text(
                                        "End : ${item.endDate ?? "-"}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BudgetVsSpendDialog extends StatefulWidget {
  const BudgetVsSpendDialog({super.key});

  @override
  State<BudgetVsSpendDialog> createState() => _BudgetVsSpendDialogState();
}

class _BudgetVsSpendDialogState extends State<BudgetVsSpendDialog> {

  AdminDashboardController adminDashboardController = Get.put(AdminDashboardController());
  final TextEditingController searchController = TextEditingController();
  String filterValue = "All Status";

  final List<String> filterItems = [
    "All Status",
    "Under",
    "Over",
    "On Track",
  ];

  late TooltipBehavior _tooltipBehavior;

  late ZoomPanBehavior _zoomPanBehavior;

  final ScrollController _horizontalScrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   adminDashboardController.filteredBudgetVsSpendList.assignAll(
    //     adminDashboardController.allBudgetVsSpendList,
    //   );
    // });
    //
    //
    // _tooltipBehavior = TooltipBehavior(
    //   enable: true,
    //   builder: (dynamic data,
    //       dynamic point,
    //       dynamic series,
    //       int pointIndex,
    //       int seriesIndex) {
    //
    //     final item = labourDashboardController.filteredProjects[pointIndex];
    //
    //     return Container(
    //       padding: const EdgeInsets.all(2),
    //       decoration: BoxDecoration(
    //         color: Colors.black87,
    //         borderRadius: BorderRadius.circular(8),
    //       ),
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //
    //           const SizedBox(height: 6),
    //
    //           if (seriesIndex == 0)
    //             Text(
    //               "NMR Nos : ${item.nmrNos?.toStringAsFixed(0) ?? "0"}",
    //               style: const TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 9,
    //               ),
    //             ),
    //
    //           if (seriesIndex == 1)
    //             Text(
    //               "Rate Nos : ${item.rateNos?.toStringAsFixed(0) ?? "0"}",
    //               style: const TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 9,
    //               ),
    //             ),
    //         ],
    //       ),
    //     );
    //   },
    // );
    //
    // _zoomPanBehavior = ZoomPanBehavior(
    //   enablePanning: true,        // allows horizontal drag/scroll
    //   enablePinching: true,       // pinch to zoom (optional)
    //   zoomMode: ZoomMode.x,       // restrict zoom/pan to X-axis only
    //   enableMouseWheelZooming: true,
    //   enableDoubleTapZooming: false,
    //   enableSelectionZooming: false,// desktop/web mouse-wheel support
    // );


  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        adminDashboardController.filteredBudgetVsSpendList.assignAll(adminDashboardController.allBudgetVsSpendList);
        searchController.clear();
        filterValue = "All Status";

        return true;
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 30,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .85,
          height: 430,
          child: Column(
            children: [

              /// Header
              Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    const SizedBox(width: 15),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Project Wise Labour Summary",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            "All Projects",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        adminDashboardController.filteredBudgetVsSpendList.assignAll(
                          adminDashboardController.allBudgetVsSpendList,
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close,size: 20,),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              /// Search & Filter
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                            controller: searchController,

                            decoration: InputDecoration(
                              isDense: true,
                              hintText: "Search",
                              prefixIcon:
                              const Icon(Icons.search),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:  BorderSide(
                                  color: Colors.grey, // Purple when focused
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              searchProjects(value);
                            }
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    SizedBox(
                      width: 140,
                      height: 36,
                      child: DropdownButtonFormField<String>(
                        value: filterValue,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          filled: true,
                          isDense: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.grey, // Purple when focused
                              width: 2,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        items: filterItems
                            .map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,style: TextStyle(fontSize: 14),),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            filterProjects(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 20,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _legend(
                      const Color(0xff2F5BEA),
                      "Budget (₹)",
                    ),
                    const SizedBox(width: 15),
                    _legend(
                      const Color(0xff34C759),
                      "Spent (₹)",
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.only(left: 5,
                    right: 5,
                    bottom: 10,
                  ),
                  child: Obx(() {
                    final chartData = adminDashboardController.filteredBudgetVsSpendList
                        .take(3)
                        .toList();

                    final axisValues = getYAxisValues(chartData);

                    return SizedBox(
                      height: 250,
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        legend:  Legend(isVisible: false),
                        margin: const EdgeInsets.only(top: 20, right: 10),

                        primaryXAxis: CategoryAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                          majorTickLines: const MajorTickLines(size: 0),
                          axisLine: const AxisLine(width: 0),
                          labelStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          labelIntersectAction: AxisLabelIntersectAction.multipleRows,
                        ),

                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: axisValues["maximum"]!,
                          interval: axisValues["interval"]!,
                          axisLine: const AxisLine(width: 0),
                          majorTickLines: const MajorTickLines(size: 0),
                          majorGridLines: MajorGridLines(
                            color: Colors.grey.shade300,
                          ),
                          axisLabelFormatter: (AxisLabelRenderDetails details) {
                            return ChartAxisLabel(
                              formatAxisLabel(details.value),
                              const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                        series: <CartesianSeries>[
                          ColumnSeries<BudgetVsSpend, String>(
                            dataSource: chartData,
                            width: 0.8,
                            spacing: 0.15,
                            color: const Color(0xff2F5BEA),

                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),

                            xValueMapper: (BudgetVsSpend item, _) =>
                                BaseUtitiles.formatProjectName(item.projectName ?? ""),

                            yValueMapper: (item, _) => parseChartValue(item.budget),
                            dataLabelMapper: (BudgetVsSpend item, _) =>
                                formatChartLabel(item.budget),
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.outer,
                              textStyle: TextStyle(
                                color: Color(0xff2F5BEA),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          ColumnSeries<BudgetVsSpend, String>(
                            dataSource: chartData,
                            width: 0.8,
                            spacing: 0.15,
                            color: const Color(0xff34C759),

                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),

                            xValueMapper: (BudgetVsSpend item, _) =>
                                BaseUtitiles.formatProjectName(item.projectName ?? ""),

                            yValueMapper: (item, _) => parseChartValue(item.spent),
                            dataLabelMapper: (BudgetVsSpend item, _) =>
                                formatChartLabel(item.spent),
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.outer,
                              textStyle: TextStyle(
                                color: Color(0xff34C759),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double parseChartValue(String? value) {
    if (value == null || value.trim().isEmpty) return 0;

    String text = value.replaceAll("₹", "").replaceAll(",", "").trim();

    if (text.endsWith("L")) {
      return (double.tryParse(text.replaceAll("L", "").trim()) ?? 0) * 100000;
    }

    if (text.endsWith("Cr")) {
      return (double.tryParse(text.replaceAll("Cr", "").trim()) ?? 0) * 10000000;
    }

    return double.tryParse(text) ?? 0;
  }

  String formatChartLabel(String? value) {
    if (value == null || value.isEmpty) return "0";

    // Don't modify values with units
    if (value.contains("L") || value.contains("Cr")) {
      return value;
    }

    final number = double.tryParse(value.replaceAll("₹", "").trim());

    if (number == null) return value;

    if (number == number.toInt()) {
      return number.toInt().toString(); // 105.00 -> 105
    }

    return number.toString(); // 100.50 -> 100.5
  }

  String formatAxisLabel(num value) {
    if (value >= 10000000) {
      return "${(value / 10000000).toStringAsFixed(2)} Cr";
    }

    if (value >= 100000) {
      return "${(value / 100000).toStringAsFixed(2)} L";
    }

    // Remove trailing .00
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        )
      ],
    );
  }

  Map<String, double> getYAxisValues(List<BudgetVsSpend> list) {
    double maxValue = 0;

    for (final item in list) {
      maxValue = math.max(
        maxValue,
        math.max(
          parseChartValue(item.budget),
          parseChartValue(item.spent),
        ),
      );
    }

    // Handle all zero values
    if (maxValue <= 0) {
      return {
        "maximum": 5,
        "interval": 1,
      };
    }

    final maximum = (maxValue * 1.1).ceilToDouble();
    final interval = math.max(1.0, maximum / 5);

    return {
      "maximum": maximum,
      "interval": interval,
    };
  }
  /// ---------- Search based on projects ----------
  void searchProjects(String query) {
    final search = query.trim().toLowerCase();

    final sourceList = adminDashboardController.allBudgetVsSpendList;


    if (search.isEmpty) {
      filterProjects(filterValue); // Retain the selected dropdown filter
      return;
    }

    adminDashboardController.filteredBudgetVsSpendList.assignAll(
      sourceList.where((item) {
        return (item.projectName ?? "")
            .trim()
            .toLowerCase()
            .contains(search);
      }).toList(),
    );

    // Apply the selected dropdown filter on the searched results
    switch (filterValue) {
      case "Under":
        adminDashboardController.filteredBudgetVsSpendList.assignAll(
          adminDashboardController.filteredBudgetVsSpendList.where((e) {
            return parseChartValue(e.budget) < parseChartValue(e.spent);
          }).toList(),
        );
        break;

      case "Over":
        adminDashboardController.filteredBudgetVsSpendList.assignAll(
          adminDashboardController.filteredBudgetVsSpendList.where((e) {
            return parseChartValue(e.spent) > parseChartValue(e.budget);
          }).toList(),
        );
        break;

      case "On Track":
        adminDashboardController.filteredBudgetVsSpendList.assignAll(
          adminDashboardController.filteredBudgetVsSpendList.where((e) {
            return (parseChartValue(e.budget) - parseChartValue(e.spent)).abs() < 0.01;
          }).toList(),
        );
        break;
    }

  }

  /// Dropdown Allstatus, under, Over ---------
  void filterProjects(String value) {
    filterValue = value;

    switch (filterValue) {
      case "Under":
        adminDashboardController.filteredBudgetVsSpendList.assignAll(
          adminDashboardController.filteredBudgetVsSpendList.where((e) {
            return parseChartValue(e.budget) < parseChartValue(e.spent);
          }).toList(),
        );
        break;

      case "Over":
        adminDashboardController.filteredBudgetVsSpendList.assignAll(
          adminDashboardController.filteredBudgetVsSpendList.where((e) {
            return parseChartValue(e.budget) < parseChartValue(e.spent);
          }).toList(),
        );
        break;

      case "On Track":
        adminDashboardController.filteredBudgetVsSpendList.assignAll(
          adminDashboardController.filteredBudgetVsSpendList.where((e) {
            return (parseChartValue(e.budget) - parseChartValue(e.spent)).abs() < 0.01;
          }).toList(),
        );
        break;
    }
  }


}
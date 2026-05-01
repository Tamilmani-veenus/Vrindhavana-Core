import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../controller/commonvoucher_controller.dart';
import '../controller/projectcontroller.dart';
import '../controller/sitecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../db_model/sitevoucherdet_model.dart';
import '../db_services/sitevoucherlist_service.dart';
import '../home/menu/accounts/site_voucher/site_voucher_new/site_voucher_entry_new.dart';
import '../home/menu/accounts/site_voucher/site_voucher_new/site_voucher_entrylist_new.dart';
import '../models/get_site_voc_image.dart';
import '../models/inwardimageres_model.dart';
import '../models/site_voc_image_delete.dart';
import '../models/site_voc_image_payload.dart';
import '../models/sitevouchersave_model.dart';
import '../provider/sitevoucher_provider.dart';
import '../utilities/baseutitiles.dart';
import '../utilities/requestconstant.dart';
import 'logincontroller.dart';

class SiteVoucher_Controller extends GetxController {
  final SiteVocEntrylistFrDate = TextEditingController();
  final SiteVocEntrylistToDate = TextEditingController();
  final AutoYearwiseSiteVoc = new TextEditingController();
  final sitevocDate = new TextEditingController();
  final DetAmount = TextEditingController();
  final Tds = TextEditingController();
  final Tdsamount = TextEditingController();
  final NetAmount = TextEditingController();
  final Amount = TextEditingController();
  final Remarks = TextEditingController();

  LoginController loginController = Get.put(LoginController());
  ProjectController projectController = Get.put(ProjectController());
  SiteController siteController = Get.put(SiteController());
  CommonVoucherController commonVoucherController =
  Get.put(CommonVoucherController());

  var sitevoucherItemListTableModel = SitevoucherDetlist();
  late List<SitevoucherDetlist> sitevoucherTableList = <SitevoucherDetlist>[];
  late List<SitevoucherDetlist> deleteModelList = <SitevoucherDetlist>[];
  RxList<AccountSiteVoucherSwPayment> getSiteDetList = <AccountSiteVoucherSwPayment>[].obs;
  var sitevoucherlistService = SitevoucherlistService();

  RxList SiteVocEtyList = [].obs;
  RxList Sitevoucher_itemview_GetDbList = [].obs;
  RxList Sitevoucher_EditListApiValue = [].obs;
  int VocID = 0;
  RxString type = "SiteWise Payment".obs;
  String edittype = "";
  RxString SaveButton = RequestConstant.SUBMIT.obs;
  RxInt? count = 0.obs;
  var imageFiles = <File>[].obs;
  bool checkImgList = false;
  List<ImageView>? gettingNetworkImages;
  List<String>? gettingNetworkImageList = [];
  RxInt? netWorkImageCount = 0.obs;
  RxInt? pickedImageCount = 0.obs;
  List<int>? imageId = [];

  clearDatas() {
    SaveButton.value = RequestConstant.SUBMIT;
    siteController.selectedsiteId = 0.obs;
    type.value = "SiteWise Payment";
    delete_Sitevoucher_itemlist_Table();
    Sitevoucher_itemview_GetDbList.clear();
    siteController.selectedsitedropdownName = "--Select--".obs;
    siteController.getSiteDropdownvalue.value.clear();
    siteController.Sitename.text = RequestConstant.SELECT;
    siteController.siteDropdownName.clear();
    commonVoucherController.VoucherTypeController.text = "Payment";
    projectController.projectname.text = "--Select--";
    commonVoucherController.VocType.value = "P";
    commonVoucherController.AccountTypename.text = "--Select--";
    commonVoucherController.Accountname.text = "--Select--";
    commonVoucherController.selectedAccnameId = 0.obs;
    commonVoucherController.setSelectedAccPayForListName("A");
    sitevocDate.text = BaseUtitiles.initiateCurrentDateFormat();
    commonVoucherController.Paymodename.text = "--Select--";
    commonVoucherController.AccPayforname.text = "--Select--";
    Remarks.text = "";
    Amount.text = "0.00";
  }

  Future getSiteVoc_EntryList() async {
    SiteVocEtyList.value.clear();
    final value = await Sitevoucher_provider.getSiteVouc_Entry_List(SiteVocEntrylistFrDate.text, SiteVocEntrylistToDate.text);
      if (value != null) {
        if(value.success==true){
          if(value.result!.isNotEmpty){
            SiteVocEtyList.value = value.result!;
          }
          else {
            BaseUtitiles.showToast(RequestConstant.NORECORD_FOUND);
          }
        }else {
          BaseUtitiles.showToast(value.message ?? 'Something went wrong..');
        }
      } else {
        BaseUtitiles.showToast("Something Went Wrong...");
      }
  }

  ///--Calculation

  calculation(double? amt, double? tds) {
    Tdsamount.text = (amt! * tds! / 100).toStringAsFixed(2);
    NetAmount.text = (amt - double.parse(Tdsamount.text)).toStringAsFixed(2);
    // Amount.text=NetAmount.text.toString();
  }

  ///---save to Db

  Sitevoucher_Save_DB(BuildContext context) async {
    sitevoucherTableList.clear();
    int j = 0;
    int amt = 0;
    int netAmount = 0;
    if(NetAmount.text == "0.0" || NetAmount.text == "0.00" || NetAmount.text == "0") {
    } else {
      sitevoucherItemListTableModel = SitevoucherDetlist();
      sitevoucherItemListTableModel.siteid = siteController.selectedsiteId.value;
      sitevoucherItemListTableModel.sitename = siteController.Sitename.text;
      sitevoucherItemListTableModel.paytype = commonVoucherController.detVocType;
      amt = double.parse(DetAmount.text).round();
      sitevoucherItemListTableModel.amt = amt.toDouble();
      sitevoucherItemListTableModel.TdsPer = double.parse(Tds.text==""?"0":Tds.text);
      sitevoucherItemListTableModel.TdsAmt = double.parse(Tdsamount.text==""?"0":Tdsamount.text);
      netAmount = double.parse(NetAmount.text).round();
      sitevoucherItemListTableModel.NetAmt = netAmount.toDouble();
      for (var element in Sitevoucher_itemview_GetDbList.value) {
        if (element.siteid == sitevoucherItemListTableModel.siteid && element.paytype == sitevoucherItemListTableModel.paytype) {
          j = 1;
          BaseUtitiles.showToast("Entry already exist");
        }
      }
      if (j == 0) {
        sitevoucherTableList.add(sitevoucherItemListTableModel);
      } else {
        j = 0;
      }
    }
    var savedatas = await sitevoucherlistService.SitevoucherItemlist_table_Save(sitevoucherTableList);
    return Navigator.pop(context, savedatas);
  }

  ///Get Values

  Future getsitevoucherTablesDatas() async {
    Sitevoucher_itemview_GetDbList.clear();
    var siteItem = await sitevoucherlistService.SitevoucherItemlist_table_readAll();
    siteItem.forEach((user) {
      var SitevoucherItemlist = SitevoucherDetlist();
      SitevoucherItemlist.siteid = user['siteid'];
      SitevoucherItemlist.sitename = user['sitename'];
      SitevoucherItemlist.paytype = user['paytype'];
      SitevoucherItemlist.amt = user['amt'];
      SitevoucherItemlist.TdsPer = user['TdsPer'];
      SitevoucherItemlist.TdsAmt = user['TdsAmt'];
      SitevoucherItemlist.NetAmt = user['NetAmt'];
      Sitevoucher_itemview_GetDbList.add(SitevoucherItemlist);
    });
  }

  netamountCalculation() {
    Amount.text = "0.0";
    int count = 0;
    if (Sitevoucher_itemview_GetDbList.value.isNotEmpty) {
      Sitevoucher_itemview_GetDbList.value.forEach((element) {
        count = (double.parse(Amount.text) + element.NetAmt).round();
        Amount.text = count.toString();
      });
      print(Amount.text);
    } else {
      Amount.text = "0.0";
    }
  }

  delete_Sitevoucher_itemlist_Table() async {
    await sitevoucherlistService.SitevoucherItemlist_table_delete();
  }

  ///Particular delete

  Future deleteParticularList(SitevoucherDetlist data) async {
    deleteModelList.clear();
    sitevoucherItemListTableModel = SitevoucherDetlist();
    sitevoucherItemListTableModel.siteid = data.siteid;
    sitevoucherItemListTableModel.paytype = data.paytype;
    deleteModelList.add(sitevoucherItemListTableModel);
    await sitevoucherlistService.SitevoucherdeleteById(deleteModelList);
  }

  ///----- POST and PUT JSON Values----

  Future  SaveButtonSitevoucher_ItemlistScreen(BuildContext context, int id) async {
    SitevoucherSaveRequest formdata = SitevoucherSaveRequest(
      id: id != 0 ? id : 0,
      siteVoucherNo: AutoYearwiseSiteVoc.text,
      siteVoucherDate: sitevocDate.text,
      siteVoucherType: commonVoucherController.VocType.value,
      projectId: projectController.selectedProjectId.value,
      companyId: 9,
      accountTypeId: commonVoucherController.selectedAccId.value,
      accountNameId: commonVoucherController.selectedAccnameId.value,
      siteVoucherAmount: double.tryParse(Amount.text),
      payForType: commonVoucherController.selectedAccPayId.value,
      payModeId: commonVoucherController.selectedPaymodeId.value,
      paidFrom: commonVoucherController.vocPaidformId,
      paymentType: type.value == "Direct Payment/Office" ? "DP" : "SP",
      nameThrough: commonVoucherController.namethrough.text,
      remarks: Remarks.text,
      companyBankId: 0,
      cheQueNo:"-",
      accountPayee: 0,
      cheQueDate: sitevocDate.text,
      requisitionId: 0,
      createdBy: int.tryParse(loginController.EmpId()),
      createdDt: BaseUtitiles().convertToUtcIso(sitevocDate.text),
      accountSiteVoucherSwPayments: getSitevoucherDet()
    );
    final list = await Sitevoucher_provider.SaveSitevoucherScreenEntryAPI(
        formdata, imageFiles, SaveButton.value, id);
    
    print(jsonEncode(formdata.toJson()));
    
    if (list != null) {
      if (list["success"] == true) {
        BaseUtitiles.showToast(list["message"]);
        await getSiteVoc_EntryList();
        clearDatas();
        BaseUtitiles.popMultiple(context, count: 3);
      }
      else {
        BaseUtitiles.popMultiple(context, count: 2);
        BaseUtitiles.showToast(list["message"] ?? 'Something went wrong..');
      }
    }
    else {
      BaseUtitiles.showToast("Something went wrong..");
      BaseUtitiles.popMultiple(context, count: 2);
    }
  }

  List<AccountSiteVoucherSwPayment>? getSitevoucherDet() {
    getSiteDetList.value.clear();
    Sitevoucher_itemview_GetDbList.value.forEach((element) {
      var list = new AccountSiteVoucherSwPayment(
        id: 0,
        siteVoucherId: 0,
        payType: element.paytype,
        projectId: projectController.selectedProjectId.value,
        siteId: element.siteid,
        purOrdmasId: 0,
        purOrdBillmasId: 0,
        workOrderId: 0,
        workId: 0,
        nmrWorkDetId: 0,
        nmrWorkId: 0,
        paymentReqId: 0,
        tdsAmount: element.TdsAmt,
        tdsPercentage: element.TdsPer,
        amount: element.amt,
        netAmount: double.tryParse(Amount.text),
        reqAmount: 0,
      );
      getSiteDetList.value.add(list);
    });
    return getSiteDetList.value;
  }

  ///----Delete---

  Future<bool> SitevoucherList_DeleteApi(int vocId) async {
    return Sitevoucher_provider.Sitevoucher_entryList_deleteAPI(vocId);
  }


  /// ---------Edit Call API----------

  Future Sitevoucher_entrylist_editSaveDetTable() async {
    sitevoucherTableList.clear();
    Sitevoucher_EditListApiValue.forEach((element) {
      element.vocEditDet.forEach((val) {
        sitevoucherItemListTableModel = new SitevoucherDetlist();
        sitevoucherItemListTableModel.siteid = val.siteId;
        sitevoucherItemListTableModel.sitename = val.siteName.toString();
        sitevoucherItemListTableModel.paytype = val.payType.toString();
        sitevoucherItemListTableModel.amt = val.amt;
        sitevoucherItemListTableModel.TdsPer = val.tdsPer;
        sitevoucherItemListTableModel.TdsAmt = val.tdsAmt;
        sitevoucherItemListTableModel.NetAmt = val.netAmt;
        sitevoucherTableList.add(sitevoucherItemListTableModel);
      });
    });
    var savedatas = await sitevoucherlistService.SitevoucherItemlist_table_Save(
        sitevoucherTableList);
    return savedatas;
  }

  Future ConsumEntryList_EditApi(int VocId, BuildContext context) async {
    await Sitevoucher_provider.Sitevoucher_entryList_editAPI(VocId).then((value) async {
      if (value != null && value.length > 0) {
        delete_Sitevoucher_itemlist_Table();
        Sitevoucher_itemview_GetDbList.clear();
        Sitevoucher_EditListApiValue.value = value;
        await Sitevoucher_entrylist_editSaveDetTable();
        await getsitevoucherTablesDatas();
        await gettingImage(VocId);
        return Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SiteVoucher_EntryScreen()));
      }
    });
  }
  
  Future DeleteAlert(BuildContext context, int index) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alert!'),
        content: Text('Do you want to Delete?'),
        actions: [
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: RequestConstant.Lable_Font_SIZE))),
                  ),
                  VerticalDivider(
                    color: Colors.grey.shade400, //color of divider
                    width: 5, //width space of divider
                    thickness: 2, //thickness of divier line
                    indent: 15, //Spacing at the top of divider.
                    endIndent: 15, //Spacing at the bottom of divider.
                  ),
                  Expanded(
                    child: TextButton(
                        onPressed: () async {
                          bool result = await SitevoucherList_DeleteApi(SiteVocEtyList[index].id);
                          if (result) {
                            SiteVocEtyList.removeAt(index);
                            Navigator.of(context).pop();
                          }
                          else{
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text("Delete",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: RequestConstant.Lable_Font_SIZE))),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sending multiple images controller.....

  Future<void> sendMultipleImage() async {
    InwardImageRes inwardImageRes =
    await Sitevoucher_provider().sendMultipleImageProvider(
        SiteVocImagePayload(
          vocId: VocID.toString(),
          vocNo: AutoYearwiseSiteVoc.text,
          entryMode: "ADD",
        ), imageFiles);
    if (inwardImageRes.retString != null) {
      if (kDebugMode) {
        print("Successfully upload the images");
        print(inwardImageRes.retString.toString());
      }
    } else {
      BaseUtitiles.showToast(RequestConstant.SOMETHINGWENT_WRONG);
    }
  }

  Future<void> sendMultipleUpdateImage() async {
    InwardImageRes inwardImageRes =
    await Sitevoucher_provider().sendMultipleImageProvider(
        SiteVocImagePayload(
          vocId: VocID.toString(),
          vocNo: AutoYearwiseSiteVoc.text,
          entryMode: "UPDATE",
        ), imageFiles);
    if (inwardImageRes.retString != null) {
      if (kDebugMode) {
        print("Successfully upload the images");
        print(inwardImageRes.retString.toString());
      }
    } else {
      BaseUtitiles.showToast(RequestConstant.SOMETHINGWENT_WRONG);
    }
  }

  /// Getting image.....

  Future<void> gettingImage(int? vocId) async {
    GetSiteVocImage gettingImage =
    await Sitevoucher_provider().gettingImageProvider(vocId);
    gettingNetworkImages = gettingImage.imageView;
    netWorkImageCount?.value = gettingImage.imageView!.length;
    print("Getting count :: $netWorkImageCount");
    if (gettingNetworkImages!.isNotEmpty) {
      checkImgList = true;
      gettingNetworkImageList!.clear();
      imageId!.clear();
      for (int i = 0; i < gettingNetworkImages!.length; i++) {
        gettingNetworkImageList!
            .add(gettingImage.imageView![i].imageUrl.toString());
        imageId!.add(int.parse(gettingImage.imageView![i].imageId.toString()));
      }
    }
  }

  /// Delete image.....

  Future<void> deletingImage(int imageId) async {
    SiteVocImageDelete siteVocImageDelete =
    await Sitevoucher_provider().deleteImageProvider(imageId);
    BaseUtitiles.showToast(siteVocImageDelete.message.toString());
  }
}

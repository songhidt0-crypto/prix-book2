/// All user-facing strings in Arabic (RTL primary language)
/// as defined in Prix Book Master Spec v1.1 Section 8.1
abstract class AppStrings {
  // App
  static const String appName = 'دفتر الأسعار';
  static const String appSubtitle = 'مقارنة أسعار الجملة';

  // Navigation tabs
  static const String tabProducts = 'المنتجات';
  static const String tabSuppliers = 'الموردون';
  static const String tabSettings = 'الإعدادات';

  // Products
  static const String products = 'المنتجات';
  static const String addProduct = 'إضافة منتج';
  static const String editProduct = 'تعديل المنتج';
  static const String productName = 'اسم المنتج';
  static const String productNameHint = 'مثال: قلم بيك، دفتر 100 ورقة';
  static const String brand = 'العلامة التجارية';
  static const String brandOptional = 'العلامة التجارية (اختياري)';
  static const String selectBrand = 'اختر علامة تجارية';
  static const String unitType = 'نوع الوحدة';
  static const String packSize = 'حجم العبوة';
  static const String packSizeHint = 'عدد القطع في العبوة';
  static const String barcode = 'الباركود';
  static const String barcodeHint = 'الباركود (اختياري)';
  static const String notes = 'ملاحظات';
  static const String notesHint = 'ملاحظات اختيارية';
  static const String addImage = 'إضافة صورة';
  static const String changeImage = 'تغيير الصورة';
  static const String removeImage = 'حذف الصورة';
  static const String deleteProduct = 'حذف المنتج';
  static const String priceHistory = 'سجل الأسعار';
  static const String priceComparison = 'مقارنة الأسعار';

  // Unit Types (Arabic labels)
  static const String unitPiece = 'قطعة';
  static const String unitBox = 'علبة';
  static const String unitCarton = 'كرتون';
  static const String unitPack = 'حزمة';
  static const String unitOther = 'أخرى';

  // Suppliers
  static const String suppliers = 'الموردون';
  static const String addSupplier = 'إضافة مورد';
  static const String editSupplier = 'تعديل بيانات المورد';
  static const String supplierName = 'اسم المورد';
  static const String supplierNameHint = 'اسم المحل أو المورد';
  static const String phone = 'رقم الهاتف';
  static const String phoneHint = '0555 123 456';
  static const String address = 'العنوان';
  static const String addressHint = 'الموقع في السوق';
  static const String lastVisit = 'آخر زيارة';
  static const String neverVisited = 'لم تتم زيارته';
  static const String markVisitedToday = 'سجّل زيارة اليوم';
  static const String deleteSupplier = 'حذف المورد';
  static const String productCount = 'منتج بسعر مسجّل';

  // Brands
  static const String brands = 'العلامات التجارية';
  static const String addBrand = 'إضافة علامة تجارية';
  static const String editBrand = 'تعديل العلامة التجارية';
  static const String brandName = 'اسم العلامة التجارية';
  static const String brandNameHint = 'مثال: BIC، Maped، Pilot';
  static const String deleteBrand = 'حذف العلامة التجارية';
  static const String noBrands = 'لا توجد علامات تجارية بعد.';
  static const String noBrandsSubtitle = 'العلامات التجارية تساعدك على تنظيم منتجاتك.';

  // Shopping Session
  static const String startSession = 'بدء جلسة تسوق';
  static const String sessionActive = 'الجلسة نشطة';
  static const String endSession = 'إنهاء';
  static const String sessionSummary = 'ملخص الجلسة';
  static const String selectSupplier = 'اختر موردًا';
  static const String switchSupplier = 'تغيير المورد';
  static const String pricesRecorded = 'سعر مسجّل';
  static const String savePrice = 'حفظ السعر';
  static const String skip = 'تخطّي';
  static const String previousPrice = 'السعر السابق';
  static const String enterPrice = 'أدخل السعر';
  static const String priceDZD = 'السعر (دج)';
  static const String sessionEnded = 'انتهت الجلسة';
  static const String sessionDuration = 'المدة';
  static const String suppliersVisited = 'موردون';
  static const String bestPriceList = 'أفضل الأسعار';
  static const String buyFrom = 'اشتر من';
  static const String activeSessionWarning =
      'لديك جلسة نشطة. أنهِها قبل البدء بجلسة جديدة.';
  static const String endAndStartNew = 'إنهاء والبدء بجلسة جديدة';

  // Prices
  static const String bestPrice = 'أفضل سعر';
  static const String perUnit = 'للقطعة';
  static const String lastUpdated = 'آخر تحديث';
  static const String recordedOn = 'مسجّل في';
  static const String unitPriceNote = 'الأسعار موضّحة بالقطعة (أحجام العبوات مختلفة)';
  static const String priceDifference = 'فرق السعر';
  static const String noPrice = 'لا يوجد سعر';
  static const String noPricesYet = 'لا توجد أسعار مسجّلة لهذا المنتج بعد.';
  static const String noPricesSubtitle = 'ابدأ جلسة تسوق لتسجيل أول سعر.';
  static const String noPriceHistory = 'لا يوجد سجل أسعار لهذا المورد والمنتج.';
  static const String priceIncreasedAlert = '⚠️ ارتفع السعر بنسبة';
  static const String since = 'منذ';
  static const String priceAgeToday = 'اليوم';
  static const String priceAgeWeek = 'هذا الأسبوع';
  static const String priceAgeMonth = 'هذا الشهر';
  static const String priceAgeOld = 'قديم';

  // Search
  static const String search = 'بحث';
  static const String searchProducts = 'ابحث عن منتج أو باركود';
  static const String searchSuppliers = 'ابحث عن مورد';
  static const String noResults = 'لا توجد نتائج لـ';
  static const String clearSearch = 'مسح البحث';

  // Settings
  static const String settings = 'الإعدادات';
  static const String manageBrands = 'إدارة العلامات التجارية';
  static const String exportBackup = 'تصدير نسخة احتياطية';
  static const String exportBackupSubtitle = 'مشاركة قاعدة البيانات لحفظها';
  static const String about = 'حول التطبيق';
  static const String version = 'الإصدار';

  // Actions
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String confirm = 'تأكيد';
  static const String close = 'إغلاق';
  static const String retry = 'إعادة المحاولة';
  static const String yes = 'نعم';
  static const String no = 'لا';

  // Confirmations
  static const String deleteProductConfirm =
      'هل تريد حذف هذا المنتج؟ سيتم حذف جميع سجلات الأسعار المرتبطة به.';
  static const String deleteSupplierConfirm =
      'هل تريد حذف هذا المورد؟ سيتم حذف جميع سجلات الأسعار المرتبطة به نهائيًا.';
  static const String deleteBrandConfirm =
      'منتجات ستصبح بدون علامة تجارية. هل تريد المتابعة؟';
  static const String deletePriceRecordConfirm =
      'هل تريد حذف هذا السجل السعري؟';
  static const String thisWillDelete = 'سيتم حذف';
  static const String priceRecords = 'سجل سعري';

  // Errors
  static const String errorRequired = 'هذا الحقل مطلوب';
  static const String errorProductNameExists = 'هذا المنتج موجود بالفعل';
  static const String errorBrandNameExists = 'هذه العلامة التجارية موجودة بالفعل';
  static const String errorSupplierNameExists = 'هذا المورد موجود بالفعل';
  static const String errorBarcodeExists = 'هذا الباركود مخصص بالفعل لـ';
  static const String errorPackSizePositive = 'يجب أن يكون حجم العبوة عددًا موجبًا';
  static const String errorValidPrice = 'أدخل سعرًا صحيحًا';
  static const String errorPriceRange = 'السعر خارج النطاق المقبول';
  static const String errorValidPhone = 'أدخل رقم هاتف صحيح';
  static const String errorFutureDate = 'لا يمكن أن تكون تاريخ الزيارة في المستقبل';
  static const String errorProductNameMax = 'اسم المنتج يجب ألا يتجاوز 100 حرف';
  static const String errorGeneric = 'حدث خطأ. يرجى المحاولة مجددًا.';
  static const String errorDbWrite = 'خطأ في حفظ البيانات. تحقق من المساحة المتاحة.';
  static const String errorFatal = 'خطأ جسيم في قاعدة البيانات';
  static const String errorFatalSubtitle =
      'يرجى التواصل مع الدعم أو إعادة ضبط قاعدة البيانات.';

  // Success
  static const String successSaved = 'تم الحفظ بنجاح';
  static const String successDeleted = 'تم الحذف';
  static const String successPriceRecorded = 'تم تسجيل السعر';
  static const String successVisitMarked = 'تم تسجيل الزيارة اليوم';

  // Empty states
  static const String emptyProducts = 'أضف أول منتج لك لبدء مقارنة الأسعار';
  static const String emptySuppliers = 'أضف موردًا لبدء تسجيل الأسعار';
  static const String emptyPriceHistory = 'لا يوجد سجل أسعار لهذا المورد والمنتج';

  // Onboarding
  static const String onboardingTitle = 'هل تريد تحميل بيانات البداية؟';
  static const String onboardingSubtitle =
      'تحتوي على علامات تجارية ومنتجات شائعة في سوق القرطاسية الجزائري.';
  static const String loadStarterData = 'تحميل البيانات';
  static const String skipOnboarding = 'تخطّي';

  // DZD currency
  static const String dzd = 'دج';
  static const String currency = 'دينار جزائري';
}

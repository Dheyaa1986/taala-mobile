class IraqGovernorate {
  final String nameAr;
  final String nameEn;

  const IraqGovernorate({
    required this.nameAr,
    required this.nameEn,
  });
}

/// المحافظات العراقية الـ 18
const List<IraqGovernorate> iraqGovernorates = [
  IraqGovernorate(nameAr: 'بغداد', nameEn: 'Baghdad'),
  IraqGovernorate(nameAr: 'البصرة', nameEn: 'Basra'),
  IraqGovernorate(nameAr: 'نينوى', nameEn: 'Nineveh'),
  IraqGovernorate(nameAr: 'أربيل', nameEn: 'Erbil'),
  IraqGovernorate(nameAr: 'السليمانية', nameEn: 'Sulaymaniyah'),
  IraqGovernorate(nameAr: 'كركوك', nameEn: 'Kirkuk'),
  IraqGovernorate(nameAr: 'الأنبار', nameEn: 'Anbar'),
  IraqGovernorate(nameAr: 'بابل', nameEn: 'Babylon'),
  IraqGovernorate(nameAr: 'كربلاء', nameEn: 'Karbala'),
  IraqGovernorate(nameAr: 'النجف', nameEn: 'Najaf'),
  IraqGovernorate(nameAr: 'ذي قار', nameEn: 'Dhi Qar'),
  IraqGovernorate(nameAr: 'ميسان', nameEn: 'Maysan'),
  IraqGovernorate(nameAr: 'المثنى', nameEn: 'Muthanna'),
  IraqGovernorate(nameAr: 'القادسية', nameEn: 'Qadisiyyah'),
  IraqGovernorate(nameAr: 'صلاح الدين', nameEn: 'Saladin'),
  IraqGovernorate(nameAr: 'واسط', nameEn: 'Wasit'),
  IraqGovernorate(nameAr: 'ديالى', nameEn: 'Diyala'),
  IraqGovernorate(nameAr: 'دهوك', nameEn: 'Dohuk'),
];

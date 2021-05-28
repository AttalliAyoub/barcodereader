enum Format {
  NONE,
  PARTIAL,
  EAN8,
  UPCE,
  ISBN10,
  UPCA,
  EAN13,
  ISBN13,
  I25,
  DATABAR,
  DATABAR_EXP,
  CODABAR,
  CODE39,
  PDF417,
  QRCODE,
  CODE93,
  CODE128,
}

String format2String(Format format) =>
    format.toString().replaceAll('Format.', '');

Format int2format(int code) {
  switch (code) {
    // No symbol decoded.
    case 0:
      return Format.NONE;
    //Symbol detected but not decoded.
    case 1:
      return Format.PARTIAL;
    //EAN-8.
    case 8:
      return Format.EAN8;
    //UPC-E.
    case 9:
      return Format.UPCE;
    //ISBN-10 (from EAN-13).
    case 10:
      return Format.ISBN10;
    //UPC-A.
    case 12:
      return Format.UPCA;
    //EAN-13.
    case 13:
      return Format.EAN13;
    //ISBN-13 (from EAN-13).
    case 14:
      return Format.ISBN13;
    //Interleaved 2 of 5.
    case 25:
      return Format.I25;
    //DataBar (RSS-14).
    case 34:
      return Format.DATABAR;
    //DataBar Expanded.
    case 35:
      return Format.DATABAR_EXP;
    //Codabar.
    case 38:
      return Format.CODABAR;
    //Code 39.
    case 39:
      return Format.CODE39;
    //PDF417.
    case 57:
      return Format.PDF417;
    //QR Code.
    case 64:
      return Format.QRCODE;
    //Code 93.
    case 93:
      return Format.CODE93;
    // Code 128.
    case 128:
      return Format.CODE128;
    default:
  }
}

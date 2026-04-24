// CarSah Dashboard Wireframe — Figma Plugin v7.6.1
// CRITICAL ARCHITECTURAL RECTIFICATION applied:
//  - Calendar Icon: double-mirroring eradicated (pure LTR coordinate)
//  - Itemized Cost Engine: per-task price inputs enforce data traceability
//  - Footer Redesign: Labor Cost (full-width) + Grand Total read-only summary
//  - I18N: strict Western numerals; [IX] -> [9] mapping
// Dashboard frozen. Screen 2.2 (Add Record Dialog) active.
// Two pages: Dashboard + Operations.

// ═══════════════════════════════════════════════════════════
// §0 — I18N DICTIONARY
// Western numerals (1,2,3,4) in ALL layouts — no Eastern Arabic numerals.
// ═══════════════════════════════════════════════════════════

const i18n = {
  "9:41": "9:41",
  "Current Odometer": "العداد الحالي",
  "Updated 2 days ago": "مُحدث منذ يومين",
  "+ UPDATE": "+ تحديث",
  "UPDATE": "تحديث",
  "Upcoming Services": "الخدمات القادمة",
  "Engine Oil Change": "تغيير زيت المحرك",
  "Air Filter": "فلتر الهواء",
  "Coolant Flush": "تغيير سائل التبريد",
  "Transmission Fluid": "زيت ناقل الحركة",
  "Overdue by": "متأخر بـ",
  "Due at": "مستحق عند",
  "Scheduled at": "مجدول عند",
  "Starts in": "يبدأ خلال",
  "URGENT": "عاجل",
  "DUE": "متأخر",
  "SCHEDULED": "مجدول",
  "UPCOMING": "قريب",
  "Home": "الرئيسية",
  "Insights": "إحصائيات",
  "History": "السجل",
  "Settings": "الإعدادات",
  "Analytics Preview [Phase C]": "معاينة الإحصائيات [المرحلة ج]",
  "Empty Database": "قاعدة بيانات فارغة",
  "No maintenance schedule found.": "لم يتم إعداد سجل الصيانة.",
  "Start Initial Setup": "بدء الإعداد الأولي",
  "Tank 300 (2024)": "تانك 300 (2024)",
  // Screen 2.2 — Add Record Dialog
  "Add Maintenance Record": "إضافة سجل صيانة",
  "Odometer": "العداد",
  "Date": "التاريخ",
  "Labor Cost": "أجور اليد",
  "Attach Invoice": "إرفاق الفاتورة",
  "Notes": "ملاحظات",
  "Save": "حفظ",
  "Select Completed Tasks": "اختر المهام المنجزة",
  "[IX] Market Benchmarking": "[9] تقييم سعر السوق",
  "SAR 0": "0 SAR",
  "Price": "السعر",
  "Total": "الإجمالي",
  "Grand Total": "المجموع الكلي",
};

function tr(enText, isRTL) {
  return isRTL && i18n[enText] ? i18n[enText] : enText;
}

// ═══════════════════════════════════════════════════════════
// §1 — DUAL MATH ENGINE
// ═══════════════════════════════════════════════════════════

function getShapeX(x, width, isRTL, frameWidth = 390) {
  return isRTL ? frameWidth - x - width : x;
}

function getTextRightEdge(leftMarginX, isRTL, frameWidth = 390) {
  return isRTL ? frameWidth - leftMarginX : leftMarginX;
}

// ═══════════════════════════════════════════════════════════
// §2 — COLOR TOKENS (MD3)
// ═══════════════════════════════════════════════════════════

const DARK = {
  bg: "#1B1B1F", card: "#211F26", cardLow: "#1D1B20",
  text: "#E6E1E5", dim: "#938F99",
  primary: "#D0BCFF", primaryCont: "#4F378B", onPrimary: "#EADDFF",
  urgent: "#F2B8B5", urgentBg: "#8C1D18",
  due: "#E8C77A", dueBg: "#4A3B00",
  upcoming: "#AEC6FF", upcomingBg: "#002E69",
  scheduled: "#A8DAB5", scheduledBg: "#1B3A24",
  outline: "#49454F",
};

const LIGHT = {
  bg: "#FAFAFA", card: "#F3EDF7", cardLow: "#F7F2FA",
  text: "#1B1B1F", dim: "#79747E",
  primary: "#5835B0", primaryCont: "#EADDFF", onPrimary: "#4F378B",
  urgent: "#BA1A1A", urgentBg: "#F2B8B5",
  due: "#7D5700", dueBg: "#E8C77A",
  upcoming: "#005AC1", upcomingBg: "#D8E2FF",
  scheduled: "#1B5E20", scheduledBg: "#A8DAB5",
  outline: "#CAC4D0",
};

// ═══════════════════════════════════════════════════════════
// §3 — FONT REGISTRY
// ═══════════════════════════════════════════════════════════

let activeFont = "Inter";
let iconFont = "Inter";
let iconsAvailable = false;

function styleMap(style) {
  if (activeFont === "Cairo") {
    if (style === "Semi Bold") return "SemiBold";
    return style || "Regular";
  } else {
    if (style === "SemiBold") return "Semi Bold";
    return style || "Regular";
  }
}

// ═══════════════════════════════════════════════════════════
// §4 — PRIMITIVE DRAWING HELPERS
// ═══════════════════════════════════════════════════════════

function hexToFill(hex) {
  const r = parseInt(hex.slice(1, 3), 16) / 255;
  const g = parseInt(hex.slice(3, 5), 16) / 255;
  const b = parseInt(hex.slice(5, 7), 16) / 255;
  return { type: "SOLID", color: { r, g, b } };
}

function rect(parent, name, x, y, w, h, color, radius, isRTL) {
  const r = figma.createRectangle();
  r.name = name;
  r.resize(w, h);
  r.x = getShapeX(x, w, isRTL);
  r.y = y;
  r.fills = [hexToFill(color)];
  if (radius) r.cornerRadius = radius;
  parent.appendChild(r);
  return r;
}

function circ(parent, name, x, y, w, h, color, isRTL) {
  const e = figma.createEllipse();
  e.name = name;
  e.resize(w, h);
  e.x = getShapeX(x, w, isRTL);
  e.y = y;
  e.fills = [hexToFill(color)];
  parent.appendChild(e);
  return e;
}

function txt(parent, name, x, y, content, size, color, style, isRTL) {
  const t = figma.createText();
  t.name = name;
  t.fontName = { family: activeFont, style: styleMap(style || "Regular") };
  t.fontSize = size;
  t.textAlignHorizontal = isRTL ? "RIGHT" : "LEFT";
  t.characters = content;
  t.fills = [hexToFill(color)];
  t.textAutoResize = "WIDTH_AND_HEIGHT";
  if (isRTL) {
    t.x = getTextRightEdge(x, true) - t.width;
  } else {
    t.x = x;
  }
  t.y = y;
  parent.appendChild(t);
  return t;
}

function txtCenter(parent, name, centerX, y, content, size, color, style, isRTL) {
  const t = figma.createText();
  t.name = name;
  t.fontName = { family: activeFont, style: styleMap(style || "Regular") };
  t.fontSize = size;
  t.textAlignHorizontal = "CENTER";
  t.characters = content;
  t.fills = [hexToFill(color)];
  t.textAutoResize = "WIDTH_AND_HEIGHT";
  t.x = centerX - (t.width / 2);
  t.y = y;
  parent.appendChild(t);
  return t;
}

const ICON_FALLBACKS = {
  "home": "HOME", "settings": "SET", "notifications": "BELL",
  "expand_more": "V", "add": "+", "edit": "EDT",
  "insights": "INS", "history": "HIS", "directions_car": "CAR",
  "schedule": "SCH", "check_circle": "OK", "warning": "WRN",
};

function icon(parent, name, x, y, iconName, size, color, isRTL) {
  const i = figma.createText();
  i.name = name;
  if (iconsAvailable) {
    i.fontName = { family: iconFont, style: "Regular" };
  } else {
    i.fontName = { family: activeFont, style: "Medium" };
  }
  i.fontSize = size;
  i.textAlignHorizontal = isRTL ? "RIGHT" : "LEFT";
  if (iconsAvailable) {
    i.characters = iconName;
  } else {
    i.characters = ICON_FALLBACKS[iconName] || iconName.substring(0, 3).toUpperCase();
  }
  i.fills = [hexToFill(color)];
  i.textAutoResize = "WIDTH_AND_HEIGHT";
  if (isRTL) {
    i.x = getTextRightEdge(x, true) - i.width;
  } else {
    i.x = x;
  }
  i.y = y;
  parent.appendChild(i);
  return i;
}

// ═══════════════════════════════════════════════════════════
// §5 — COMPONENT FACTORY
// ═══════════════════════════════════════════════════════════

// Status bar — NEVER mirrors
function buildStatusbar(frame, theme) {
  rect(frame, "Status Bar BG", 0, 0, 390, 44, theme.bg, 0, false);
  txt(frame, "Time", 24, 14, "9:41", 14, theme.text, "SemiBold", false);
  txt(frame, "Status Icons", 310, 15, "LTE  WiFi  Batt", 10, theme.dim, "Regular", false);
}

// App Bar — icon primitive for chevron, Western numerals for year
function buildAppBar(frame, theme, isRTL) {
  rect(frame, "App Bar BG", 0, 44, 390, 64, theme.bg, 0, isRTL);

  const vehicleName = tr("Tank 300 (2024)", isRTL);

  if (isRTL) {
    // RTL: [expand_more icon] + [تانك 300 (2024)]
    icon(frame, "Chevron", 16, 66, "expand_more", 16, theme.dim, isRTL);
    txt(frame, "Vehicle Name", 36, 66, vehicleName, 14, theme.text, "Medium", isRTL);
  } else {
    // LTR: [Tank 300 (2024)] + [expand_more icon]
    txt(frame, "Vehicle Name", 16, 66, vehicleName, 14, theme.text, "Medium", isRTL);
    const nameWidth = vehicleName.length * 8;
    const chevronX = 16 + nameWidth + 8;
    icon(frame, "Chevron", chevronX, 66, "expand_more", 16, theme.dim, isRTL);
  }

  // Trailing icons
  icon(frame, "Bell Icon", 320, 64, "notifications", 20, theme.text, isRTL);
  circ(frame, "Badge BG", 330, 58, 16, 16, theme.urgent, isRTL);
  txt(frame, "Badge Count", 335, 62, "3", 9, "#000000", "Bold", isRTL);
  icon(frame, "Gear Icon", 356, 64, "settings", 20, theme.text, isRTL);
}

// ╔═══════════════════════════════════════════════════════════╗
// ║ TASK CARD — ABSOLUTE PM COORDINATES                      ║
// ║ Badge BG and Badge Text use HARDCODED absolute x/y.       ║
// ║ isRTL = FALSE passed to primitives for badges so the      ║
// ║ math engine is BYPASSED — coordinates are final.          ║
// ╚═══════════════════════════════════════════════════════════╝

function buildTaskCard(frame, yPos, titleEn, prefixEn, kmValue, statusTypeEn, theme, isRTL) {
  const title = tr(titleEn, isRTL);
  const prefix = tr(prefixEn, isRTL);
  const subtitle = prefix + " " + kmValue;
  const statusType = tr(statusTypeEn, isRTL);

  // Color map
  let c;
  if (statusTypeEn === "URGENT")        c = { dot: theme.urgent,    bg: theme.urgentBg,    text: theme.urgent };
  else if (statusTypeEn === "DUE")      c = { dot: theme.due,       bg: theme.dueBg,       text: theme.due };
  else if (statusTypeEn === "UPCOMING") c = { dot: theme.upcoming,  bg: theme.upcomingBg,  text: theme.upcoming };
  else                                  c = { dot: theme.scheduled, bg: theme.scheduledBg, text: theme.scheduled };

  // Card background — LTR coordinates, primitives mirror
  rect(frame, titleEn + " — Card BG", 16, yPos, 358, 88, theme.cardLow, 12, isRTL);

  // Status dot — LTR coordinates
  circ(frame, titleEn + " — Dot", 32, yPos + 20, 8, 8, c.dot, isRTL);

  // Text content — LTR coordinates
  txt(frame, titleEn + " — Name", 48, yPos + 14, title, 16, theme.text, "SemiBold", isRTL);
  txt(frame, titleEn + " — Subtitle", 48, yPos + 36, subtitle, 12, theme.dim, "Regular", isRTL);

  // ═══════════════════════════════════════════════════════════
  // BADGE — ABSOLUTE PM COORDINATES (Math Engine Bypassed)
  // ═══════════════════════════════════════════════════════════

  const badgeW = 80;
  const badgeH = 20;
  const badgeFontSize = 10;

  let badgeBgX, badgeTextX, badgeY;

  if (isRTL) {
    if (statusTypeEn === "URGENT")      { badgeBgX = 266; badgeTextX = 295; badgeY = 355; }
    else if (statusTypeEn === "DUE")    { badgeBgX = 266; badgeTextX = 288; badgeY = 450; }
    else if (statusTypeEn === "UPCOMING") { badgeBgX = 266; badgeTextX = 292; badgeY = 546; }
    else if (statusTypeEn === "SCHEDULED") { badgeBgX = 266; badgeTextX = 290; badgeY = 642; }
  } else {
    if (statusTypeEn === "URGENT")      { badgeBgX = 48; badgeTextX = 70; badgeY = 355; }
    else if (statusTypeEn === "DUE")    { badgeBgX = 48; badgeTextX = 79; badgeY = 450; }
    else if (statusTypeEn === "UPCOMING") { badgeBgX = 48; badgeTextX = 64; badgeY = 546; }
    else if (statusTypeEn === "SCHEDULED") { badgeBgX = 48; badgeTextX = 62; badgeY = 642; }
  }

  // Badge BG — pass isRTL=false so getShapeX does NOT mirror the absolute X
  const badgeBg = figma.createRectangle();
  badgeBg.name = titleEn + " — Badge BG";
  badgeBg.resize(badgeW, badgeH);
  badgeBg.x = badgeBgX;
  badgeBg.y = badgeY;
  badgeBg.fills = [hexToFill(c.bg)];
  badgeBg.cornerRadius = 10;
  frame.appendChild(badgeBg);

  // Badge Text — pass isRTL=false so getTextRightEdge does NOT mirror the absolute X
  const badgeTextY = badgeY + (badgeH - badgeFontSize) / 2 - 1;
  const badgeTextNode = figma.createText();
  badgeTextNode.name = titleEn + " — Badge Text";
  badgeTextNode.fontName = { family: activeFont, style: styleMap("Bold") };
  badgeTextNode.fontSize = badgeFontSize;
  badgeTextNode.textAlignHorizontal = "LEFT"; // always LEFT — absolute X
  badgeTextNode.characters = statusType;
  badgeTextNode.fills = [hexToFill(c.text)];
  badgeTextNode.textAutoResize = "WIDTH_AND_HEIGHT";
  badgeTextNode.x = badgeTextX;
  badgeTextNode.y = badgeTextY;
  frame.appendChild(badgeTextNode);

  return yPos + 88 + 8;
}

function buildBottomNav(frame, activeTabEn, theme, isRTL) {
  rect(frame, "Bottom Nav BG", 0, 764, 390, 80, theme.card, 0, isRTL);

  const tabs = [
    { labelEn: "Home",      icon: "home" },
    { labelEn: "Insights",  icon: "insights" },
    { labelEn: "History",   icon: "history" },
    { labelEn: "Settings",  icon: "settings" },
  ];
  const positions = [25, 124, 217, 320];

  for (let i = 0; i < tabs.length; i++) {
    const label = tr(tabs[i].labelEn, isRTL);
    const isActive = tabs[i].labelEn === activeTabEn;
    const tabX = positions[i];

    if (isActive) {
      rect(frame, "Nav — " + tabs[i].labelEn + " Active BG", tabX, 778, 64, 48, theme.primaryCont, 16, isRTL);
      icon(frame, "Nav — " + tabs[i].labelEn + " Icon", tabX + 22, 782, tabs[i].icon, 20, theme.primary, isRTL);
      txt(frame, "Nav — " + tabs[i].labelEn + " Label", tabX + 14, 808, label, 12, theme.primary, "Medium", isRTL);
    } else {
      icon(frame, "Nav — " + tabs[i].labelEn + " Icon", tabX + 22, 782, tabs[i].icon, 20, theme.dim, isRTL);
      txt(frame, "Nav — " + tabs[i].labelEn + " Label", tabX + 14, 808, label, 12, theme.dim, "Medium", isRTL);
    }
  }
}

function buildReservedSlot(frame, x, y, w, h, label, phase, theme, isRTL) {
  const d = 1;
  rect(frame, label + " — Border Top",    x,         y,         w, d, theme.outline, 0, isRTL);
  rect(frame, label + " — Border Bottom",  x,         y + h - d, w, d, theme.outline, 0, isRTL);
  rect(frame, label + " — Border Left",    x,         y,         d, h, theme.outline, 0, isRTL);
  rect(frame, label + " — Border Right",   x + w - d, y,         d, h, theme.outline, 0, isRTL);

  const bg = figma.createRectangle();
  bg.name = label + " — Slot BG";
  bg.resize(w, h);
  bg.x = getShapeX(x, w, isRTL);
  bg.y = y;
  bg.fills = [{ type: "SOLID", color: hexToFill(theme.cardLow).color, opacity: 0.3 }];
  bg.cornerRadius = 12;
  frame.appendChild(bg);

  const centerX = x + w / 2;
  txtCenter(frame, label + " — Label", centerX, y + h / 2 - 8, label, 12, theme.dim, "Medium", isRTL);
}

// ═══════════════════════════════════════════════════════════
// §5b — EMPTY STATE COMPONENT (Virgin State)
// ═══════════════════════════════════════════════════════════

function buildEmptyState(frame, yStart, illustrationLabelEn, messageEn, ctaTextEn, ctaStyle, theme, isRTL) {
  const illustrationLabel = tr(illustrationLabelEn, isRTL);
  const message = tr(messageEn, isRTL);
  const ctaText = tr(ctaTextEn, isRTL);

  const frameCenter = 390 / 2;
  const illW = 120;
  const illH = 120;
  const illX = frameCenter - illW / 2;
  const illY = yStart + 40;

  const illBox = figma.createRectangle();
  illBox.name = "Empty State — " + illustrationLabelEn + " Placeholder";
  illBox.resize(illW, illH);
  illBox.x = illX;
  illBox.y = illY;
  illBox.fills = [{ type: "SOLID", color: hexToFill(theme.cardLow).color, opacity: 0.5 }];
  illBox.cornerRadius = 16;
  frame.appendChild(illBox);

  const d = 1;
  const dashFrame = figma.createFrame();
  dashFrame.name = "Empty — Illust Borders";
  dashFrame.resize(illW, illH);
  dashFrame.x = illX;
  dashFrame.y = illY;
  dashFrame.fills = [];
  frame.appendChild(dashFrame);

  const borders = [
    { name: "Top",    x: 0, y: 0,        w: illW, h: d },
    { name: "Bottom", x: 0, y: illH - d, w: illW, h: d },
    { name: "Left",   x: 0, y: 0,        w: d,    h: illH },
    { name: "Right",  x: illW - d, y: 0, w: d,    h: illH },
  ];
  for (const b of borders) {
    const br = figma.createRectangle();
    br.name = "Empty — Illust Border " + b.name;
    br.resize(b.w, b.h);
    br.x = b.x;
    br.y = b.y;
    br.fills = [hexToFill(theme.outline)];
    dashFrame.appendChild(br);
  }

  icon(frame, "Empty — Illust Icon", frameCenter - 14, illY + 32, "directions_car", 28, theme.dim, isRTL);
  txtCenter(frame, "Empty — Illust Label", frameCenter, illY + 72, illustrationLabel, 11, theme.dim, "Regular", isRTL);
  txtCenter(frame, "Empty — Message", frameCenter, illY + illH + 24, message, 14, theme.text, "Medium", isRTL);

  const ctaW = Math.max(ctaText.length * 8 + 48, 140);
  const ctaH = 40;
  const ctaX = frameCenter - ctaW / 2;
  const ctaY = illY + illH + 64;

  if (ctaStyle === "primary") {
    rect(frame, "Empty — CTA BG", ctaX, ctaY, ctaW, ctaH, theme.primaryCont, 20, isRTL);
    const ctaTextY = ctaY + (ctaH - 14) / 2 - 1;
    txtCenter(frame, "Empty — CTA Text", frameCenter, ctaTextY, ctaText, 14, theme.onPrimary, "Medium", isRTL);
  } else {
    const ctaBg = figma.createRectangle();
    ctaBg.name = "Empty — CTA BG";
    ctaBg.resize(ctaW, ctaH);
    ctaBg.x = ctaX;
    ctaBg.y = ctaY;
    ctaBg.fills = [];
    ctaBg.strokes = [hexToFill(theme.primary)];
    ctaBg.strokeWeight = 1.5;
    ctaBg.cornerRadius = 20;
    frame.appendChild(ctaBg);

    const ctaTextY = ctaY + (ctaH - 14) / 2 - 1;
    txtCenter(frame, "Empty — CTA Text", frameCenter, ctaTextY, ctaText, 14, theme.primary, "Medium", isRTL);
  }

  return ctaY + ctaH + 16;
}

// ═══════════════════════════════════════════════════════════
// §6 — SCREEN BUILDER: DASHBOARD (Screen 2.1) — v7.5 FINAL
// ═══════════════════════════════════════════════════════════

function buildDashboardScreen(frame, theme, isRTL) {
  const frameCenter = 390 / 2;

  // Status bar — NEVER mirrors
  buildStatusbar(frame, theme);

  // App Bar
  buildAppBar(frame, theme, isRTL);

  // Odometer Card
  rect(frame, "Odometer BG", 16, 108, 358, 140, theme.card, 16, isRTL);
  txt(frame, "Odometer Value", 32, 128, "106,807 km", 32, theme.text, "Bold", isRTL);
  txt(frame, "Odometer Label", 32, 168, tr("Current Odometer", isRTL), 12, theme.dim, "Regular", isRTL);
  txt(frame, "Odometer Updated", 32, 184, tr("Updated 2 days ago", isRTL), 12, theme.dim, "Regular", isRTL);

  // Update button
  rect(frame, "Update Odo BTN", 258, 196, 100, 36, theme.primaryCont, 20, isRTL);
  icon(frame, "Update Icon", 270, 202, "edit", 14, theme.onPrimary, isRTL);
  txt(frame, "Update Odo TXT", 288, 206, tr("UPDATE", isRTL), 14, theme.onPrimary, "Medium", isRTL);

  // Section Header
  txt(frame, "Section — Upcoming Services", 16, 268, tr("Upcoming Services", isRTL), 16, theme.text, "SemiBold", isRTL);

  // 4 Task Cards
  let nextY = 296;
  nextY = buildTaskCard(frame, nextY, "Engine Oil Change", "Overdue by", "6,807 km", "URGENT", theme, isRTL);
  nextY = buildTaskCard(frame, nextY, "Air Filter", "Due at", "110,000 km", "DUE", theme, isRTL);
  nextY = buildTaskCard(frame, nextY, "Transmission Fluid", "Starts in", "2,500 km", "UPCOMING", theme, isRTL);
  nextY = buildTaskCard(frame, nextY, "Coolant Flush", "Scheduled at", "120,000 km", "SCHEDULED", theme, isRTL);

  // Analytics Preview
  const analyticsY = nextY + 8;
  rect(frame, "Analytics BG", 16, analyticsY, 358, 100, theme.bg, 16, isRTL);
  txtCenter(frame, "Analytics Label", frameCenter, analyticsY + 32, tr("Analytics Preview [Phase C]", isRTL), 14, theme.dim, "Medium", isRTL);

  // Bottom Navigation
  buildBottomNav(frame, "Home", theme, isRTL);

  // FAB
  circ(frame, "FAB BG", 318, 724, 56, 56, theme.primaryCont, isRTL);
  const fabIconX = isRTL ? 32 : 334;
  icon(frame, "FAB Icon", fabIconX, 740, "add", 24, theme.onPrimary, false);
}

// ═══════════════════════════════════════════════════════════
// §6b — SCREEN BUILDER: DASHBOARD VIRGIN STATE
// ═══════════════════════════════════════════════════════════

function buildDashboardVirginState(frame, theme, isRTL) {
  const frameCenter = 390 / 2;

  buildStatusbar(frame, theme);

  // Minimal app bar
  rect(frame, "App Bar BG", 0, 44, 390, 64, theme.bg, 0, isRTL);
  txt(frame, "App Title", 16, 66, "CarSah (2024)", 14, theme.text, "Medium", isRTL);

  // Virgin State
  buildEmptyState(
    frame,
    108,
    "Empty Database",
    "No maintenance schedule found.",
    "Start Initial Setup",
    "primary",
    theme,
    isRTL
  );

  buildBottomNav(frame, "Home", theme, isRTL);
  circ(frame, "FAB BG", 318, 724, 56, 56, theme.primaryCont, isRTL);
  const fabIconX = isRTL ? 32 : 334;
  icon(frame, "FAB Icon", fabIconX, 740, "add", 24, theme.onPrimary, false);
}

// ═══════════════════════════════════════════════════════════
// §6c — SCREEN BUILDER: ADD RECORD DIALOG (Screen 2.2)
// Full-screen dialog. theme.bg background.
// All LTR coordinates. Primitives handle mirroring.
// ═══════════════════════════════════════════════════════════

function buildAddRecordScreen(frame, theme, isRTL) {
  const frameCenter = 390 / 2;

  // Status bar — NEVER mirrors
  buildStatusbar(frame, theme);

  // ═══════════════════════════════════════════════════════
  // TOP BAR — Close icon (leading), Title (center), Save (trailing)
  // ═══════════════════════════════════════════════════════
  rect(frame, "Top Bar BG", 0, 44, 390, 64, theme.bg, 0, isRTL);

  // Close icon — LTR x=16 (leading)
  icon(frame, "Close Icon", 16, 64, "close", 20, theme.text, isRTL);

  // Title — centered
  txtCenter(frame, "Dialog Title", frameCenter, 66, tr("Add Maintenance Record", isRTL), 16, theme.text, "SemiBold", isRTL);

  // Save button — LTR x=330 (trailing)
  txt(frame, "Save Button", 330, 66, tr("Save", isRTL), 14, theme.primary, "Medium", isRTL);

  // ── Odometer Field (MD3 Outlined Text Field, h=56) ──
  let fieldY = 124;

  rect(frame, "Odometer Field BG", 16, fieldY, 358, 56, theme.card, 12, isRTL);
  // Label (floating) — LTR x=24
  txt(frame, "Odometer Label", 24, fieldY - 6, tr("Odometer", isRTL), 12, theme.dim, "Regular", isRTL);
  // Placeholder value
  txt(frame, "Odometer Placeholder", 24, fieldY + 22, "106,807", 16, theme.text, "Regular", isRTL);

  fieldY += 72;

  // ── Date Field (MD3 Outlined Text Field with calendar icon) ──
  rect(frame, "Date Field BG", 16, fieldY, 358, 56, theme.card, 12, isRTL);
  txt(frame, "Date Label", 24, fieldY - 6, tr("Date", isRTL), 12, theme.dim, "Regular", isRTL);
  txt(frame, "Date Placeholder", 24, fieldY + 22, "2024/04/22", 16, theme.text, "Regular", isRTL);
  // Calendar icon — trailing (LTR coordinate only; primitive handles RTL mirroring)
  icon(frame, "Calendar Icon", 348, fieldY + 18, "calendar_month", 20, theme.dim, isRTL);

  fieldY += 72;

  // ═══════════════════════════════════════════════════════
  // TASK CHECKLIST MODULE
  // ═══════════════════════════════════════════════════════
  txt(frame, "Checklist Header", 16, fieldY, tr("Select Completed Tasks", isRTL), 14, theme.text, "SemiBold", isRTL);
  fieldY += 24;

  const checkItems = ["Engine Oil Change", "Air Filter", "Coolant Flush"];
  for (let i = 0; i < checkItems.length; i++) {
    const itemY = fieldY + i * 44;

    // Row background
    rect(frame, checkItems[i] + " Row BG", 16, itemY, 358, 40, theme.cardLow, 8, isRTL);

    // Checkbox — LTR x=28
    rect(frame, checkItems[i] + " Checkbox", 28, itemY + 10, 20, 20, theme.bg, 4, isRTL);
    rect(frame, checkItems[i] + " Checkbox Border", 28, itemY + 10, 20, 20, theme.outline, 4, isRTL);
    // Checkbox border (thin stroke via separate rects)
    const cbd = 1;
    const cbx = 28, cby = itemY + 10, cbw = 20, cbh = 20;
    rect(frame, checkItems[i] + " CB Top",    cbx, cby, cbw, cbd, theme.outline, 0, isRTL);
    rect(frame, checkItems[i] + " CB Bottom", cbx, cby + cbh - cbd, cbw, cbd, theme.outline, 0, isRTL);
    rect(frame, checkItems[i] + " CB Left",   cbx, cby, cbd, cbh, theme.outline, 0, isRTL);
    rect(frame, checkItems[i] + " CB Right",  cbx + cbw - cbd, cby, cbd, cbh, theme.outline, 0, isRTL);

    // Task name — LTR x=56 (leading)
    txt(frame, checkItems[i] + " Label", 56, itemY + 12, tr(checkItems[i], isRTL), 14, theme.text, "Regular", isRTL);

    // ── Itemized Price Input (trailing) — MD3 style ──
    rect(frame, checkItems[i] + " Price BG", 260, itemY + 6, 100, 28, theme.card, 8, isRTL);
    txt(frame, checkItems[i] + " Price Label", 266, itemY + 2, tr("Price", isRTL), 10, theme.dim, "Regular", isRTL);
    txt(frame, checkItems[i] + " Price Placeholder", 266, itemY + 16, "0", 12, theme.text, "Regular", isRTL);
  }

  fieldY += checkItems.length * 44 + 16;

  // ═══════════════════════════════════════════════════════
  // COST FOOTER — Labor Cost + Grand Total
  // ═══════════════════════════════════════════════════════

  // Labor Cost — full width (LTR x=16)
  rect(frame, "Labor Cost BG", 16, fieldY, 358, 56, theme.card, 12, isRTL);
  txt(frame, "Labor Cost Label", 24, fieldY - 6, tr("Labor Cost", isRTL), 12, theme.dim, "Regular", isRTL);
  txt(frame, "Labor Cost Placeholder", 24, fieldY + 22, "0", 16, theme.text, "Regular", isRTL);

  fieldY += 72;

  // Grand Total — read-only summary (sum of itemized parts + labor)
  rect(frame, "Grand Total BG", 16, fieldY, 358, 40, theme.cardLow, 8, isRTL);
  txt(frame, "Grand Total Label", 24, fieldY + 12, tr("Grand Total", isRTL), 14, theme.text, "SemiBold", isRTL);
  txt(frame, "Grand Total Value", 260, fieldY + 12, tr("SAR 0", isRTL), 14, theme.primary, "SemiBold", isRTL);

  fieldY += 56;

  // ── Reserved Slot: Market Benchmarking [IX] ──
  buildReservedSlot(frame, 16, fieldY, 358, 36, "[IX] Market Benchmarking", "IX", theme, isRTL);

  fieldY += 52;

  // ═══════════════════════════════════════════════════════
  // INVOICE CAMERA SLOT (120dp height, dashed border)
  // ═══════════════════════════════════════════════════════
  const invW = 358;
  const invH = 120;
  const invX = 16;

  // Dashed border (4 thin rects)
  const d = 1;
  rect(frame, "Invoice — Border Top",    invX,         fieldY,         invW, d, theme.outline, 0, isRTL);
  rect(frame, "Invoice — Border Bottom",  invX,         fieldY + invH - d, invW, d, theme.outline, 0, isRTL);
  rect(frame, "Invoice — Border Left",    invX,         fieldY,         d, invH, theme.outline, 0, isRTL);
  rect(frame, "Invoice — Border Right",   invX + invW - d, fieldY,    d, invH, theme.outline, 0, isRTL);

  // Slot background
  const invBg = figma.createRectangle();
  invBg.name = "Invoice — Slot BG";
  invBg.resize(invW, invH);
  invBg.x = getShapeX(invX, invW, isRTL);
  invBg.y = fieldY;
  invBg.fills = [{ type: "SOLID", color: hexToFill(theme.cardLow).color, opacity: 0.3 }];
  invBg.cornerRadius = 12;
  frame.appendChild(invBg);

  // Camera icon — centered
  icon(frame, "Invoice — Camera Icon", frameCenter - 14, fieldY + 28, "add_a_photo", 28, theme.dim, isRTL);

  // Label — centered
  txtCenter(frame, "Invoice — Label", frameCenter, fieldY + 68, tr("Attach Invoice", isRTL), 14, theme.dim, "Medium", isRTL);

  // ── Notes Field (optional, at bottom) ──
  fieldY += invH + 16;
  rect(frame, "Notes BG", 16, fieldY, 358, 80, theme.card, 12, isRTL);
  txt(frame, "Notes Label", 24, fieldY - 6, tr("Notes", isRTL), 12, theme.dim, "Regular", isRTL);
}
// ═══════════════════════════════════════════════════════════

async function main() {
  try {
    // ── TEXT FONT PRE-LOADER ──
    const requiredTextFonts = [
      { family: "Cairo", style: "Regular" },
      { family: "Cairo", style: "Medium" },
      { family: "Cairo", style: "SemiBold" },
      { family: "Cairo", style: "Bold" },
      { family: "Inter", style: "Regular" },
      { family: "Inter", style: "Medium" },
      { family: "Inter", style: "Semi Bold" },
      { family: "Inter", style: "Bold" },
    ];

    let preferredFont = "Inter";
    for (const font of requiredTextFonts) {
      try {
        await figma.loadFontAsync(font);
        if (font.family === "Cairo" && font.style === "Regular") {
          preferredFont = "Cairo";
        }
      } catch (e) {
        if (font.family === "Inter") {
          throw new Error("CRITICAL: Inter font '" + font.style + "' failed to load.");
        }
        console.warn("[CarSah] Font not available:", font.family, font.style);
      }
    }
    activeFont = preferredFont;

    // ── ICON FONT PRE-LOADER (Safeguarded) ──
    try {
      await figma.loadFontAsync({ family: "Material Symbols Outlined", style: "Regular" });
      iconFont = "Material Symbols Outlined";
      iconsAvailable = true;
    } catch (e1) {
      try {
        await figma.loadFontAsync({ family: "Material Icons", style: "Regular" });
        iconFont = "Material Icons";
        iconsAvailable = true;
      } catch (e2) {
        iconsAvailable = false;
        iconFont = activeFont;
      }
    }

    // ── BUILD VARIANTS ──
    const page = figma.currentPage;
    page.name = "CarSah — Flow 2 — Dashboard";

    const richVariants = [
      { name: "Dashboard — Dark LTR",  theme: DARK,  x: 0,    isRTL: false },
      { name: "Dashboard — Light LTR", theme: LIGHT, x: 420,  isRTL: false },
      { name: "Dashboard — Dark RTL",  theme: DARK,  x: 840,  isRTL: true  },
      { name: "Dashboard — Light RTL", theme: LIGHT, x: 1260, isRTL: true  },
    ];

    const virginVariants = [
      { name: "Dashboard Virgin — Dark LTR",  theme: DARK,  x: 0,    isRTL: false },
      { name: "Dashboard Virgin — Light LTR", theme: LIGHT, x: 420,  isRTL: false },
      { name: "Dashboard Virgin — Dark RTL",  theme: DARK,  x: 840,  isRTL: true  },
      { name: "Dashboard Virgin — Light RTL", theme: LIGHT, x: 1260, isRTL: true  },
    ];

    const addRecordVariants = [
      { name: "Add Record — Dark LTR",  theme: DARK,  x: 0,    isRTL: false },
      { name: "Add Record — Light LTR", theme: LIGHT, x: 420,  isRTL: false },
      { name: "Add Record — Dark RTL",  theme: DARK,  x: 840,  isRTL: true  },
      { name: "Add Record — Light RTL", theme: LIGHT, x: 1260, isRTL: true  },
    ];

    const allFrames = [];

    // Row 1: Data-Rich Dashboard (4 tasks)
    for (const v of richVariants) {
      try {
        const frame = figma.createFrame();
        frame.name = v.name;
        frame.resize(390, 844);
        frame.x = v.x;
        frame.y = 0;
        frame.fills = [hexToFill(v.theme.bg)];
        page.appendChild(frame);
        buildDashboardScreen(frame, v.theme, v.isRTL);
        allFrames.push(frame);
      } catch (frameErr) {
        figma.notify("CRASH in " + v.name + ": " + frameErr.message, { error: true, timeout: 10000 });
        console.error("[CarSah] Frame error:", v.name, frameErr);
      }
    }

    // Row 2: Virgin States
    for (const v of virginVariants) {
      try {
        const frame = figma.createFrame();
        frame.name = v.name;
        frame.resize(390, 844);
        frame.x = v.x;
        frame.y = 900;
        frame.fills = [hexToFill(v.theme.bg)];
        page.appendChild(frame);
        buildDashboardVirginState(frame, v.theme, v.isRTL);
        allFrames.push(frame);
      } catch (frameErr) {
        figma.notify("CRASH in " + v.name + ": " + frameErr.message, { error: true, timeout: 10000 });
        console.error("[CarSah] Frame error:", v.name, frameErr);
      }
    }

    // ── PAGE 2: Screen 2.2 — Add Record Dialog ──
    const page2 = figma.createPage();
    page2.name = "CarSah — Flow 2 — Operations";

    for (const v of addRecordVariants) {
      try {
        const frame = figma.createFrame();
        frame.name = v.name;
        frame.resize(390, 844);
        frame.x = v.x;
        frame.y = 0;
        frame.fills = [hexToFill(v.theme.bg)];
        page2.appendChild(frame);
        buildAddRecordScreen(frame, v.theme, v.isRTL);
        allFrames.push(frame);
      } catch (frameErr) {
        figma.notify("CRASH in " + v.name + ": " + frameErr.message, { error: true, timeout: 10000 });
        console.error("[CarSah] Frame error:", v.name, frameErr);
      }
    }

    if (allFrames.length > 0) {
      figma.viewport.scrollAndZoomIntoView(allFrames.slice(0, Math.min(4, allFrames.length)));
    }

    figma.notify(
      "CarSah v7.6 — " + allFrames.length + " frames across 2 pages | " +
      "Page 1: Dashboard (8) | Page 2: Add Record (4) | " +
      "Font: " + activeFont + " | Icons: " + (iconsAvailable ? iconFont : "fallback"),
      { timeout: 6000 }
    );

  } catch (err) {
    figma.notify("CRASH: " + err.message, { error: true, timeout: 10000 });
    console.error("[CarSah] FATAL:", err);
  }

  figma.closePlugin();
}

main();

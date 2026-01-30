# Arena Flow - Design System Quick Reference

## 🎨 Color Palette

```dart
// Primary
AppColors.primary // Blue - Use for headers, primary buttons, main actions

// Status
AppColors.liveGreen // ✅ Live/Active matches
AppColors.scheduledOrange // 📅 Scheduled
Colors.grey // ⏹️ Completed

// Form
Colors.grey[300] // Borders
Colors.grey[600] // Icons
Colors.grey[50] // Fill background
```

## 📝 Form Fields - Copy & Paste Template

```dart
TextFormField(
  controller: _controller,
  decoration: InputDecoration(
    labelText: 'Label Text',
    prefixIcon: Icon(Icons.icon_name, color: Colors.grey[600]),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: Colors.grey[50],
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  },
)
```

## 🔘 Button - Copy & Paste Template

```dart
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: () { /* action */ },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
    ),
    child: const Text(
      'Button Text',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  ),
)
```

## 📋 Card - Copy & Paste Template

```dart
Card(
  margin: const EdgeInsets.only(bottom: 12),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: InkWell(
    onTap: () { /* action */ },
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Content here
        ],
      ),
    ),
  ),
)
```

## 📐 Spacing Guidelines

| Use Case | Size | Example |
|----------|------|---------|
| Between form fields | 14px | `SizedBox(height: 14)` |
| Between form sections | 24-28px | `SizedBox(height: 24)` |
| Large spacing | 32px | `SizedBox(height: 32)` |
| Card padding | 16px | `padding: EdgeInsets.all(16)` |
| Page padding | 16-20px | `padding: EdgeInsets.all(20)` |
| Icon-to-text | 6-8px | `SizedBox(width: 8)` |

## 🎯 Typography Standards

```dart
// Headers
Text(
  'Main Title',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
)

// Section Headers
Text(
  'Section',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
)

// Form Labels
Text(
  'Form Label',
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.grey,
  ),
)

// Body Text
Text(
  'Body text',
  style: TextStyle(
    fontSize: 14,
    color: Colors.grey[700],
  ),
)
```

## 🏗️ Common Layouts

### Form with Sections
```dart
Column(
  children: [
    _buildFormSection(
      title: 'Section 1',
      children: [
        /* form fields */
      ],
    ),
    const SizedBox(height: 24),
    _buildFormSection(
      title: 'Section 2',
      children: [
        /* form fields */
      ],
    ),
  ],
)

Widget _buildFormSection({
  required String title,
  required List<Widget> children,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 12),
      ...children,
    ],
  );
}
```

### Data Table
```dart
Container(
  margin: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    children: [
      // Header row
      Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            /* header cells */
          ],
        ),
      ),
      // Data rows
      ...List.generate(dataLength, (index) {
        return Container(
          decoration: BoxDecoration(
            color: index.isOdd ? Colors.grey[50] : Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              /* row cells */
            ],
          ),
        );
      }),
    ],
  ),
)
```

## 🎭 Status Badges

```dart
// Live (Green)
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: AppColors.liveGreen,
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Text(
    'LIVE',
    style: TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    ),
  ),
)

// Scheduled (Orange)
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: AppColors.scheduledOrange,
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Text(
    'SCHEDULED',
    style: TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

## 📱 Responsive Tips

```dart
// Use Expanded for flexible width
Row(
  children: [
    Expanded(
      child: Text('Auto width'),
    ),
    SizedBox(width: 100),
  ],
)

// Use maxLines and ellipsis for overflow
Text(
  longText,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)

// Use Flexible for proportional widths
Row(
  children: [
    Flexible(child: Text('Takes 50%')),
    Flexible(child: Text('Takes 50%')),
  ],
)
```

## 🚀 AppBar Template

```dart
AppBar(
  title: const Text('Page Title'),
  backgroundColor: AppColors.primary,
  foregroundColor: Colors.white,
  elevation: 0,
  actions: [
    IconButton(
      icon: const Icon(Icons.action),
      onPressed: () { /* action */ },
      tooltip: 'Action',
    ),
  ],
)
```

## 📖 Import Required

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
```

---

## 🎓 Design Principles Applied

1. **Hierarchy** - Clear visual hierarchy through sizing and weight
2. **Consistency** - Uniform styling across similar elements
3. **Simplicity** - Clean, uncluttered design
4. **Accessibility** - Good contrast, readable text, large touch targets
5. **Feedback** - Loading states, focus states, validation
6. **Responsiveness** - Works on all screen sizes

---

**Remember:** Consistency makes the app look professional. Always use these templates!

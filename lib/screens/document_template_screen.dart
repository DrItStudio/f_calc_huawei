import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../ads_controller.dart';
import '../screens/vip.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum LogoPosition { left, center, right }

class LineData {
  String text;
  String? rightText;
  bool isSplit;
  bool bold;
  bool italic;
  bool strike;
  bool underline;
  TextAlign align;
  TextAlign rightAlign;
  double fontSize;
  LineData({
    this.text = '',
    this.rightText,
    this.isSplit = false,
    this.bold = false,
    this.italic = false,
    this.strike = false,
    this.underline = false,
    this.align = TextAlign.left,
    this.rightAlign = TextAlign.right,
    this.fontSize = 16,
  });
}

class DocumentTemplateScreen extends StatefulWidget {
  @override
  State<DocumentTemplateScreen> createState() => _DocumentTemplateScreenState();
}

class _DocumentTemplateScreenState extends State<DocumentTemplateScreen> {
  final TextEditingController templateNameController = TextEditingController();

  List<String> savedTemplates = [];
  String? logoPath;
  LogoPosition logoPosition = LogoPosition.left;
  double logoWidth = 48;
  double logoHeight = 48;
  bool alignLogoAndHeader = false;
  List<LineData> headerLines = [LineData()];
  List<LineData> footerLines = [LineData()];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _deleteTemplate(String name) async {
    final prefs = await SharedPreferences.getInstance();
    // Удаляем все связанные с шаблоном данные
    await prefs.remove('logo_path_$name');
    await prefs.remove('logo_position_$name');
    await prefs.remove('logo_width_$name');
    await prefs.remove('logo_height_$name');
    await prefs.remove('align_logo_header_$name');
    await prefs.remove('header_lines_$name');
    await prefs.remove('footer_lines_$name');
    // Удаляем из списка шаблонов
    List<String> templates = prefs.getStringList('doc_templates') ?? [];
    templates.remove(name);
    await prefs.setStringList('doc_templates', templates);
    setState(() {
      savedTemplates = templates;
      if (templateNameController.text == name) {
        templateNameController.clear();
        logoPath = null;
        headerLines = [LineData()];
        footerLines = [LineData()];
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('template_deleted'.tr(args: [name]))));
  }

  Future<bool?> showRewardedInfoDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
            SizedBox(width: 8),
            Text(
              'pro_or_video_title'.tr(),
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'pro_or_video_desc'.tr(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('buy_pro_btn'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('watch_video_btn'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedTemplates = prefs.getStringList('doc_templates') ?? [];
    });
  }

  Future<void> _saveTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    final name = templateNameController.text.trim();
    if (name.isEmpty) return;
    await prefs.setString('logo_path_$name', logoPath ?? '');
    await prefs.setInt('logo_position_$name', logoPosition.index);
    await prefs.setDouble('logo_width_$name', logoWidth);
    await prefs.setDouble('logo_height_$name', logoHeight);
    await prefs.setBool('align_logo_header_$name', alignLogoAndHeader);

    await prefs.setString('header_lines_$name', _linesToJson(headerLines));
    await prefs.setString('footer_lines_$name', _linesToJson(footerLines));

    List<String> templates = prefs.getStringList('doc_templates') ?? [];
    if (!templates.contains(name)) {
      templates.add(name);
      await prefs.setStringList('doc_templates', templates);
    }
    setState(() {
      savedTemplates = templates;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('saveTemplate'.tr(args: [name]))));
  }

  Future<void> _loadTemplateByName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    templateNameController.text = name;
    final loadedLogoPath = prefs.getString('logo_path_$name');
    logoPath = (loadedLogoPath != null && loadedLogoPath.isNotEmpty)
        ? loadedLogoPath
        : null;
    final posIdx = prefs.getInt('logo_position_$name');
    if (posIdx != null) logoPosition = LogoPosition.values[posIdx];
    logoWidth = prefs.getDouble('logo_width_$name') ?? 48;
    logoHeight = prefs.getDouble('logo_height_$name') ?? 48;
    alignLogoAndHeader = prefs.getBool('align_logo_header_$name') ?? false;

    headerLines = _linesFromJson(prefs.getString('header_lines_$name'));
    footerLines = _linesFromJson(prefs.getString('footer_lines_$name'));
    setState(() {});
  }

  String _linesToJson(List<LineData> lines) {
    return lines
        .map((l) => '${l.text.replaceAll('\$', r'\$')}\$'
            '${l.rightText?.replaceAll('\$', r'\$') ?? ''}\$'
            '${l.isSplit ? 1 : 0}\$'
            '${l.bold ? 1 : 0}\$'
            '${l.italic ? 1 : 0}\$'
            '${l.strike ? 1 : 0}\$'
            '${l.underline ? 1 : 0}\$'
            '${l.align.index}\$'
            '${l.rightAlign.index}\$'
            '${l.fontSize}')
        .join('\n');
  }

  List<LineData> _linesFromJson(String? data) {
    if (data == null || data.isEmpty) return [LineData()];
    return data.split('\n').map((line) {
      final parts = line.split('\$');
      if (parts.length < 2) return LineData(text: line);
      final text = parts[0].replaceAll(r'\$', '\$');
      final rightText = parts[1].replaceAll(r'\$', '\$');
      final isSplit = parts.length > 2 ? parts[2] == '1' : false;
      final bold = parts.length > 3 ? parts[3] == '1' : false;
      final italic = parts.length > 4 ? parts[4] == '1' : false;
      final strike = parts.length > 5 ? parts[5] == '1' : false;
      final underline = parts.length > 6 ? parts[6] == '1' : false;
      final alignIndex = parts.length > 7 ? int.tryParse(parts[7]) ?? 0 : 0;
      final rightAlignIndex =
          parts.length > 8 ? int.tryParse(parts[8]) ?? 2 : 2;
      final fontSize =
          parts.length > 9 ? double.tryParse(parts[9]) ?? 16.0 : 16.0;
      return LineData(
        text: text,
        rightText: rightText.isNotEmpty ? rightText : null,
        isSplit: isSplit,
        bold: bold,
        italic: italic,
        strike: strike,
        underline: underline,
        align: TextAlign.values[alignIndex],
        rightAlign: TextAlign.values[rightAlignIndex],
        fontSize: fontSize,
      );
    }).toList();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        logoPath = picked.path;
      });
    }
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 2,
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText.tr(),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  Widget _buildLogoPositionMenu() {
    return PopupMenuButton<LogoPosition>(
      icon: Icon(Icons.format_align_center,
          color: Theme.of(context).colorScheme.primary),
      tooltip: 'Position Logo'.tr(),
      onSelected: (position) {
        setState(() {
          logoPosition = position;
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: LogoPosition.left,
          child: Row(
            children: [
              Icon(
                Icons.format_align_left,
                color: logoPosition == LogoPosition.left
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color,
              )
            ],
          ),
        ),
        PopupMenuItem(
          value: LogoPosition.center,
          child: Row(
            children: [
              Icon(
                Icons.format_align_center,
                color: logoPosition == LogoPosition.center
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color,
              ),
              SizedBox(width: 8),
              Text('Center'.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: LogoPosition.right,
          child: Row(
            children: [
              Icon(
                Icons.format_align_right,
                color: logoPosition == LogoPosition.right
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color,
              ),
              SizedBox(width: 8),
              Text('Right'.tr()),
            ],
          ),
        ),
      ],
    );
  }

// ...existing code...

  Widget _buildLineEditor(List<LineData> lines, int i, VoidCallback onChanged) {
    final line = lines[i];
    final controller = TextEditingController(text: line.text);
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);

    final rightController = TextEditingController(text: line.rightText ?? '');
    rightController.selection =
        TextSelection.collapsed(offset: rightController.text.length);

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Инструменты всегда видимы
            Row(
              children: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.text_format,
                      color: Theme.of(context).colorScheme.primary),
                  tooltip: 'Text Formatting'.tr(),
                  onSelected: (value) {
                    setState(() {
                      switch (value) {
                        case 'bold':
                          line.bold = !line.bold;
                          break;
                        case 'italic':
                          line.italic = !line.italic;
                          break;
                        case 'underline':
                          line.underline = !line.underline;
                          break;
                        case 'strike':
                          line.strike = !line.strike;
                          break;
                      }
                    });
                    onChanged();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'bold',
                      child: Row(
                        children: [
                          Icon(Icons.format_bold,
                              color: line.bold
                                  ? Theme.of(context).colorScheme.primary
                                  : null),
                          SizedBox(width: 8),
                          Text('Bold'.tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'italic',
                      child: Row(
                        children: [
                          Icon(Icons.format_italic,
                              color: line.italic
                                  ? Theme.of(context).colorScheme.primary
                                  : null),
                          SizedBox(width: 8),
                          Text('Italic'.tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'underline',
                      child: Row(
                        children: [
                          Icon(Icons.format_underline,
                              color: line.underline
                                  ? Theme.of(context).colorScheme.primary
                                  : null),
                          SizedBox(width: 8),
                          Text('Underline'.tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'strike',
                      child: Row(
                        children: [
                          Icon(Icons.format_strikethrough,
                              color: line.strike
                                  ? Theme.of(context).colorScheme.primary
                                  : null),
                          SizedBox(width: 8),
                          Text('Strike'.tr()),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildLogoPositionMenu(),
                IconButton(
                  icon: Icon(Icons.keyboard_return,
                      color: Theme.of(context).colorScheme.primary),
                  tooltip: 'New Line'.tr(),
                  onPressed: () {
                    setState(() {
                      lines.insert(i + 1, LineData());
                    });
                    onChanged();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.open_in_full,
                      color: Theme.of(context).colorScheme.primary),
                  tooltip: 'Fullscreen'.tr(),
                  onPressed: () {
                    _showFullScreenEditor(controller, line, false, onChanged);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.view_week,
                    color: line.isSplit
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3),
                  ),
                  tooltip: 'Split'.tr(),
                  onPressed: () {
                    setState(() {
                      line.isSplit = !line.isSplit;
                      if (line.isSplit && line.rightText == null)
                        line.rightText = '';
                    });
                    onChanged();
                  },
                ),
                if (lines.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Line'.tr(),
                    onPressed: () {
                      setState(() {
                        lines.removeAt(i);
                      });
                      onChanged();
                    },
                  ),
                if (line.isSplit)
                  IconButton(
                    icon: Icon(Icons.open_in_full,
                        color: Theme.of(context).colorScheme.primary),
                    tooltip: 'Fullscreen'.tr(),
                    onPressed: () {
                      _showFullScreenEditor(
                          rightController, line, true, onChanged);
                    },
                  ),
              ],
            ),
            if (line.isSplit)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(
                        fontWeight:
                            line.bold ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                            line.italic ? FontStyle.italic : FontStyle.normal,
                        decoration: line.strike
                            ? TextDecoration.lineThrough
                            : (line.underline
                                ? TextDecoration.underline
                                : TextDecoration.none),
                        fontSize: line.fontSize,
                      ),
                      textAlign: line.align,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: null,
                      onChanged: (val) {
                        line.text = val;
                        onChanged();
                      },
                      decoration: _inputDecoration('Enter text'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: rightController,
                      style: TextStyle(
                        fontWeight:
                            line.bold ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                            line.italic ? FontStyle.italic : FontStyle.normal,
                        decoration: line.strike
                            ? TextDecoration.lineThrough
                            : (line.underline
                                ? TextDecoration.underline
                                : TextDecoration.none),
                        fontSize: line.fontSize,
                      ),
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: null,
                      onChanged: (val) {
                        line.rightText = val;
                        onChanged();
                      },
                      decoration: _inputDecoration('Right'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(
                        fontWeight:
                            line.bold ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                            line.italic ? FontStyle.italic : FontStyle.normal,
                        decoration: line.strike
                            ? TextDecoration.lineThrough
                            : (line.underline
                                ? TextDecoration.underline
                                : TextDecoration.none),
                        fontSize: line.fontSize,
                      ),
                      textAlign: line.align,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: null,
                      onChanged: (val) {
                        line.text = val;
                        onChanged();
                      },
                      decoration: _inputDecoration('Enter text'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinesEditor(
      String title, List<LineData> lines, VoidCallback onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
        ...List.generate(
            lines.length, (i) => _buildLineEditor(lines, i, onChanged)),
        SizedBox(height: 8),
      ],
    );
  }

  void _showFullScreenEditor(TextEditingController controller, LineData line,
      bool isRight, VoidCallback onChanged) {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('fullscreen'.tr()),
            actions: [
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller,
              autofocus: true,
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontWeight: line.bold ? FontWeight.bold : FontWeight.normal,
                fontStyle: line.italic ? FontStyle.italic : FontStyle.normal,
                decoration: line.strike
                    ? TextDecoration.lineThrough
                    : (line.underline
                        ? TextDecoration.underline
                        : TextDecoration.none),
                fontSize: line.fontSize,
              ),
              textAlign: isRight ? TextAlign.right : TextAlign.left,
              onChanged: (val) {
                if (isRight) {
                  line.rightText = val;
                } else {
                  line.text = val;
                }
                onChanged();
              },
              decoration: _inputDecoration(isRight ? 'Right' : 'Enter text'),
            ),
          ),
        );
      },
    );
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        title: Text('preview'.tr()),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (logoPath != null && alignLogoAndHeader)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildPreviewLines(headerLines),
                      ),
                    ),
                    SizedBox(width: 12),
                    Image.file(
                      File(logoPath!),
                      width: logoWidth,
                      height: logoHeight,
                    ),
                  ],
                ),
              if (logoPath != null && !alignLogoAndHeader)
                Align(
                  alignment: _getLogoAlignment(),
                  child: Image.file(
                    File(logoPath!),
                    width: logoWidth,
                    height: logoHeight,
                  ),
                ),
              if (logoPath == null || !alignLogoAndHeader)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildPreviewLines(headerLines),
                ),
              Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildPreviewLines(footerLines),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            child: Text('close'.tr()),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Alignment _getLogoAlignment() {
    switch (logoPosition) {
      case LogoPosition.left:
        return Alignment.centerLeft;
      case LogoPosition.center:
        return Alignment.center;
      case LogoPosition.right:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  List<Widget> _buildPreviewLines(List<LineData> lines) {
    return lines.map((line) {
      if (line.isSplit) {
        return Row(
          children: [
            Expanded(
              child: Text(
                line.text,
                style: TextStyle(
                  fontWeight: line.bold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: line.italic ? FontStyle.italic : FontStyle.normal,
                  decoration: line.strike
                      ? TextDecoration.lineThrough
                      : (line.underline
                          ? TextDecoration.underline
                          : TextDecoration.none),
                  fontSize: line.fontSize,
                ),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            Expanded(
              child: Text(
                line.rightText ?? '',
                style: TextStyle(
                  fontWeight: line.bold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: line.italic ? FontStyle.italic : FontStyle.normal,
                  decoration: line.strike
                      ? TextDecoration.lineThrough
                      : (line.underline
                          ? TextDecoration.underline
                          : TextDecoration.none),
                  fontSize: line.fontSize,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        );
      } else {
        return Text(
          line.text,
          style: TextStyle(
            fontWeight: line.bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: line.italic ? FontStyle.italic : FontStyle.normal,
            decoration: line.strike
                ? TextDecoration.lineThrough
                : (line.underline
                    ? TextDecoration.underline
                    : TextDecoration.none),
            fontSize: line.fontSize,
          ),
          textAlign: line.align,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/appbar_icon.png',
              height: 32,
              width: 32,
              color: Theme.of(context).iconTheme.color,
            ),
            SizedBox(width: 12),
            Expanded(
              child: AutoSizeText(
                'templateName'.tr(), // или другой ключ, если нужно
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                minFontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (!AdsController().isSubscribed) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      title: Row(
                        children: [
                          Icon(Icons.workspace_premium,
                              color: Color(0xFFFFD700), size: 28),
                          SizedBox(width: 10),
                          Text(
                            'pro_offer_title'.tr(),
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'pro_offer_desc'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Color(0xFFFFD700)),
                              SizedBox(width: 8),
                              Text('pro_feature_export'.tr(),
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Color(0xFFFFD700)),
                              SizedBox(width: 8),
                              Text('pro_feature_no_ads'.tr(),
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Color(0xFFFFD700)),
                              SizedBox(width: 8),
                              Text('pro_feature_templates'.tr(),
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('later_btn'.tr(),
                              style: TextStyle(color: Colors.white70)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VipScreen()),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium,
                                  color: Colors.black),
                              SizedBox(width: 8),
                              Text('buy_pro_btn'.tr()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AdsController().isSubscribed
                      ? Color(0xFFFFD700)
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AdsController().isSubscribed ? 'PRO' : 'Lite',
                  style: TextStyle(
                    color: AdsController().isSubscribed
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // --- Иконка предпросмотра ниже ---
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.visibility,
                      color: Theme.of(context).colorScheme.primary, size: 28),
                  tooltip: 'preview'.tr(),
                  onPressed: _showPreview,
                ),
              ),
            ),
            // --- Остальной ваш контент ---
            Text('templateName'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: templateNameController,
                    decoration: _inputDecoration('enterTemplateName'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.primary),
                  tooltip: 'chooseTemplate'.tr(),
                  onSelected: (name) => _loadTemplateByName(name),
                  itemBuilder: (context) => savedTemplates
                      .map((name) => PopupMenuItem(
                            value: name,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(name)),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'deleteTemplate'.tr(),
                                  onPressed: () async {
                                    Navigator.pop(context); // Закрыть меню
                                    await _deleteTemplate(name);
                                  },
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  style: _buttonStyle(),
                  icon: Icon(Icons.image),
                  label: Text('addLogoBtn'.tr()),
                  onPressed: _pickLogo,
                ),
                if (logoPath != null && logoPath!.isNotEmpty) ...[
                  SizedBox(width: 12),
                  Image.file(
                    File(logoPath!),
                    width: 48,
                    height: 48,
                  ),
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.red),
                    tooltip: 'deleteLogoBtn'.tr(),
                    onPressed: () => setState(() => logoPath = null),
                  ),
                ]
              ],
            ),
            if (logoPath != null) ...[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogoPositionMenu(),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.swap_vert,
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: TextEditingController(
                          text: logoWidth.round().toString()),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('width'),
                      onSubmitted: (v) {
                        final val = int.tryParse(v) ?? 48;
                        setState(
                            () => logoWidth = val.clamp(24, 200).toDouble());
                      },
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: logoWidth,
                      min: 24,
                      max: 200,
                      divisions: 20,
                      label: logoWidth.round().toString(),
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (v) => setState(() => logoWidth = v),
                    ),
                  ),
                  Icon(Icons.swap_vert,
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: TextEditingController(
                          text: logoHeight.round().toString()),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('height'),
                      onSubmitted: (v) {
                        final val = int.tryParse(v) ?? 48;
                        setState(
                            () => logoHeight = val.clamp(24, 200).toDouble());
                      },
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: logoHeight,
                      min: 24,
                      max: 200,
                      divisions: 20,
                      label: logoHeight.round().toString(),
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (v) => setState(() => logoHeight = v),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.vertical_align_center,
                      color: alignLogoAndHeader
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                    ),
                    tooltip: 'alignLogoHeader'.tr(),
                    onPressed: () => setState(
                        () => alignLogoAndHeader = !alignLogoAndHeader),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16),
            _buildLinesEditor('header', headerLines, () => setState(() {})),
            _buildLinesEditor('footer', footerLines, () => setState(() {})),
            SizedBox(height: 16),
            ElevatedButton.icon(
              style: _buttonStyle(),
              icon: Icon(Icons.save),
              label: Text('saveTemplate'.tr()),
              onPressed: _saveTemplate,
            ),
          ],
        ),
      ),
    );
  } // Форматирование даты

  String formatDate(DateTime date, String format) {
    switch (format) {
      case 'dd.MM.yyyy':
        return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'd MMMM yyyy':
        return '${date.day} ${_monthName(date.month)} ${date.year}';
      default:
        return date.toString();
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'month_january',
      'month_february',
      'month_march',
      'month_april',
      'month_may',
      'month_june',
      'month_july',
      'month_august',
      'month_september',
      'month_october',
      'month_november',
      'month_december'
    ];
    return months[month].tr();
  }
}

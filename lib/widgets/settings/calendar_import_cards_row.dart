import 'package:flutter/material.dart';
import '../../models/calendar_import_config.dart';
import 'calendar_import_card.dart';

class CalendarImportCardsRow extends StatefulWidget {
  final List<CalendarImportConfig> configs;
  final Function(int, CalendarImportConfig) onConfigChanged;

  const CalendarImportCardsRow({
    Key? key,
    required this.configs,
    required this.onConfigChanged,
  }) : super(key: key);

  @override
  _CalendarImportCardsRowState createState() => _CalendarImportCardsRowState();
}

class _CalendarImportCardsRowState extends State<CalendarImportCardsRow> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrows());
  }

  void _updateArrows() {
    if (!_scrollController.hasClients) return;
    
    final hasScroll = _scrollController.position.maxScrollExtent > 0;
    final showLeft = _scrollController.offset > 0;
    final showRight = _scrollController.offset < _scrollController.position.maxScrollExtent;

    if (_showLeftArrow != showLeft || _showRightArrow != showRight) {
      setState(() {
        _showLeftArrow = showLeft;
        _showRightArrow = hasScroll && showRight;
      });
    }
  }

  void _scroll(double offset) {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrows);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.configs.asMap().entries.map((entry) {
                final index = entry.key;
                final config = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CalendarImportCard(
                    config: config,
                    onChanged: (newConfig) => widget.onConfigChanged(index, newConfig),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (_showLeftArrow)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => _scroll(-320),
              ),
            ),
          ),
        if (_showRightArrow)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () => _scroll(320),
              ),
            ),
          ),
      ],
    );
  }
}

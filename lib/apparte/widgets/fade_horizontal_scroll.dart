import 'package:flutter/material.dart';

class FadeHorizontalScroll extends StatefulWidget {
  final Widget child;
  final double fadeWidth; // Largura do gradiente em cada lado
  final Color fadeColor; // Cor base para o gradiente (geralmente fundo do card)

  const FadeHorizontalScroll({
    super.key,
    required this.child,
    this.fadeWidth = 30.0,
    required this.fadeColor,
  });

  @override
  State<FadeHorizontalScroll> createState() => _FadeHorizontalScrollState();
}

class _FadeHorizontalScrollState extends State<FadeHorizontalScroll> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = true; // Inicialmente assume que pode rolar para direita

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateFades);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateFades);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFades() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    setState(() {
      _showLeftFade = currentScroll > 0;
      _showRightFade = currentScroll < maxScroll;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: widget.child,
            ),
            // Fade esquerdo
            if (_showLeftFade)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: widget.fadeWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        widget.fadeColor,
                        widget.fadeColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            // Fade direito
            if (_showRightFade)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: widget.fadeWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        widget.fadeColor,
                        widget.fadeColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'app_text.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final Function(int) onPageChanged;
  final bool isLoading;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.light
                ? Colors.grey[200]!
                : Colors.grey[800]!,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navegação de páginas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão primeira página
                _buildPageButton(
                  context,
                  icon: Icons.first_page,
                  onTap: currentPage > 1 ? () => onPageChanged(1) : null,
                ),
                const SizedBox(width: 4),

                // Botão anterior
                _buildPageButton(
                  context,
                  icon: Icons.navigate_before,
                  onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                ),
                const SizedBox(width: 8),

                // Indicador de página atual
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 40,
                          height: 20,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : TextBody2(
                          '$currentPage de $totalPages',
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                ),
                const SizedBox(width: 8),

                // Botão próximo
                _buildPageButton(
                  context,
                  icon: Icons.navigate_next,
                  onTap: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
                ),
                const SizedBox(width: 4),

                // Botão última página
                _buildPageButton(
                  context,
                  icon: Icons.last_page,
                  onTap: currentPage < totalPages ? () => onPageChanged(totalPages) : null,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),

          // Informações de total de itens
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: TextCaption(
              'Total: $totalItems registro(s)',
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(BuildContext context, {required IconData icon, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isEnabled
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled
                ? theme.colorScheme.primary
                : theme.brightness == Brightness.light
                    ? Colors.grey[400]
                    : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

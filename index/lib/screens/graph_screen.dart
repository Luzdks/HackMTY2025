import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aporte a la Causa'),
        backgroundColor: AppColors.darkestBlue,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Impacto del Último Año',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkestBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Total aportado: \$215.40',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 24),
            // --- GRÁFICO (Placeholder) ---
            // En una app real, reemplazarías esto con un paquete
            // como 'fl_chart' y datos reales.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Aportes Mensuales (Ejemplo)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    // Placeholder visual del gráfico
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: AppColors.almostWhiteBlue,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.paleBlue),
                      ),
                      child: const Center(
                        child: Text(
                          '', // [Imagen de un gráfico de barras financiero]
                          style: TextStyle(color: AppColors.mediumBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
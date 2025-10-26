// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart'; // Importamos colores
import '../graph_screen.dart'; // Importamos la pantalla del gráfico

class FinanceTab extends StatefulWidget {
  const FinanceTab({super.key});

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {

  // Función para mostrar el modal de inversión
  void _showInvestmentModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invertir Monedas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkestBlue,
                ),
              ),
              const SizedBox(height: 20),
              // Opciones de inversión
              _buildInvestmentOption(ctx, 'Bajo Riesgo', '500 monedas', AppColors.mediumBlue),
              _buildInvestmentOption(ctx, 'Medio Riesgo', '1000 monedas', AppColors.ceruleanBlue),
              _buildInvestmentOption(ctx, 'Alto Riesgo', '1250 monedas', AppColors.darkBlue),
              const SizedBox(height: 24),
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () { 
                        Navigator.of(ctx).pop(); 
                        // TODO: Lógica de retirar
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.mediumBlue,
                        side: const BorderSide(color: AppColors.mediumBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Retirar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () { 
                        Navigator.of(ctx).pop();
                        // TODO: Lógica de dar permisos
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Dar Permisos'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // Helper para el modal
  Widget _buildInvestmentOption(BuildContext ctx, String title, String amount, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        trailing: Text(amount, style: const TextStyle(fontSize: 16, color: AppColors.darkText)),
        onTap: () { /* Lógica para seleccionar opción */ },
      ),
    );
  }

  // Función para ir a la pantalla del gráfico
  void _showGraphScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const GraphScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
      ),
      body: Column(
        children: [
          // --- 1. SALDO DISPONIBLE (FIJO) ---
          _buildFixedBalanceCard(context),

          // --- 2. RESTO DEL CONTENIDO (CON SCROLL) ---
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding inferior para el FAB
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 3. MONEDAS PARA EL AMBIENTE ---
                    _buildSectionTitle('Monedero ambiental'),
                    _buildEcoCoinsCard(),
                    
                    const SizedBox(height: 24),

                    // --- 4. APORTE A LA CAUSA ---
                    _buildSectionTitle('Aporte a la causa'),
                    _buildCauseCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el saldo fijo y botones
  Widget _buildFixedBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      // Usamos los colores oscuros de la paleta para el fondo
      color: AppColors.darkBlue, 
      child: SafeArea(
        bottom: false, // Solo padding superior
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo disponible',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.paleBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '\$1,500.00',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Botones de Meter/Sacar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { /* TODO: Lógica Meter Dinero */ },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Meter dinero'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightCyan,
                      foregroundColor: AppColors.darkestBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { /* TODO: Lógica Sacar Dinero */ },
                    icon: const Icon(Icons.remove, size: 20),
                    label: const Text('Sacar dinero'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white.withOpacity(0.2),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: AppColors.white.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper para títulos de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.darkestBlue,
        ),
      ),
    );
  }

  // Tarjeta de Monedas
  Widget _buildEcoCoinsCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.eco, color: AppColors.cyan, size: 40),
        title: const Text('Monedas acumuladas', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('1,250 monedas'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.greyText),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        onTap: _showInvestmentModal, // Muestra el modal
      ),
    );
  }

  // Tarjeta de Aporte
  Widget _buildCauseCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.pie_chart, color: AppColors.mediumBlue, size: 40),
        title: const Text('Ver mi impacto anual', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Total aportado: \$215.40'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.greyText),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        onTap: _showGraphScreen, // Va a la pantalla del gráfico
      ),
    );
  }
}
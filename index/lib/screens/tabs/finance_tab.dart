// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para el campo de texto numérico
import '../../theme/app_colors.dart'; // Importamos colores
import '../graph_screen.dart'; // Importamos la pantalla del gráfico

class FinanceTab extends StatefulWidget {
  const FinanceTab({super.key});

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  // --- Variables de Estado (MODIFICADAS) ---
  double _saldoDisponible = 1500.00;
  // int _monedasAmbientales = 1250; // --- ELIMINADA --- Ya no la necesitamos
  int _monedasInvertidas = 0; // Para la lógica de "Retirar"

  // --- Helper para mostrar SnackBars (mensajes de éxito/error) ---
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      ),
    );
  }

  // --- Lógica para "Meter" y "Sacar" dinero (Sin cambios) ---
  void _showAmountDialog({required bool isDepositing}) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(isDepositing ? 'Meter Dinero' : 'Sacar Dinero'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Monto',
            prefixText: '\$ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              Navigator.of(ctx).pop(); 

              if (amount <= 0) return; 

              setState(() {
                if (isDepositing) {
                  _saldoDisponible += amount;
                  _showSnackBar('¡Depósito exitoso por \$${amount.toStringAsFixed(2)}!');
                } else {
                  if (amount > _saldoDisponible) {
                    _showSnackBar('Fondos insuficientes.', isError: true);
                  } else {
                    _saldoDisponible -= amount;
                    _showSnackBar('Retiro exitoso por \$${amount.toStringAsFixed(2)}!');
                  }
                }
              });
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // --- Lógica para el modal de Inversión (MODIFICADA) ---
  void _showInvestmentModal() {
    int? selectedAmount; // Cantidad de MONEDAS seleccionadas

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, modalSetState) {
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
                  _buildInvestmentOption(
                    'Bajo Riesgo', '500 monedas', AppColors.mediumBlue,
                    isSelected: selectedAmount == 500,
                    onTap: () => modalSetState(() => selectedAmount = 500),
                  ),
                  _buildInvestmentOption(
                    'Medio Riesgo', '1000 monedas', AppColors.ceruleanBlue,
                    isSelected: selectedAmount == 1000,
                    onTap: () => modalSetState(() => selectedAmount = 1000),
                  ),
                  _buildInvestmentOption(
                    'Alto Riesgo', '1250 monedas', AppColors.darkBlue,
                    isSelected: selectedAmount == 1250,
                    onTap: () => modalSetState(() => selectedAmount = 1250),
                  ),
                  const SizedBox(height: 24),
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          // --- LÓGICA DE RETIRAR (MODIFICADA) ---
                          onPressed: () {
                            Navigator.of(ctx).pop(); 
                            if (_monedasInvertidas == 0) {
                              _showSnackBar('No tienes monedas invertidas para retirar.', isError: true);
                            } else {
                              // Asumimos 1 moneda = $1
                              double cashBack = _monedasInvertidas.toDouble();
                              
                              setState(() {
                                // Devuelve el valor de las monedas al saldo principal
                                _saldoDisponible += cashBack;
                                _monedasInvertidas = 0; // Resetea la inversión
                              });
                              _showSnackBar('¡Inversión retirada! Se añadieron \$${cashBack.toStringAsFixed(2)} a tu saldo.');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.mediumBlue,
                            side: const BorderSide(color: AppColors.mediumBlue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Retirar Todo'), // Texto actualizado
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          // --- LÓGICA DE DAR PERMISOS (MODIFICADA) ---
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            
                            if (selectedAmount == null) {
                              _showSnackBar('Por favor, selecciona un monto para invertir.', isError: true);
                              return;
                            }

                            // Asumimos 1 moneda = $1
                            double costOfInvestment = selectedAmount!.toDouble();

                            if (costOfInvestment > _saldoDisponible) {
                              _showSnackBar('No tienes suficiente saldo disponible para esta inversión.', isError: true);
                            } else {
                              // Usamos setState de la PANTALLA PRINCIPAL
                              setState(() {
                                _saldoDisponible -= costOfInvestment; // Resta del saldo
                                _monedasInvertidas += selectedAmount!; // Suma a las monedas
                              });
                              _showSnackBar('¡Inversión de $selectedAmount monedas exitosa!');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBlue,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Invertir'), // Texto actualizado
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper para el modal. (Sin cambios)
  Widget _buildInvestmentOption(String title, String amount, Color color,
      {required bool isSelected, required VoidCallback onTap}) {
    return Card(
      color: isSelected ? color.withOpacity(0.2) : AppColors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        trailing: Text(amount, style: const TextStyle(fontSize: 16, color: AppColors.darkText)),
        onTap: onTap,
        leading: isSelected 
          ? Icon(Icons.check_circle, color: color) 
          : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
      ),
    );
  }

  // Función para ir a la pantalla del gráfico (sin cambios)
  void _showGraphScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const GraphScreen()),
    );
  }

  // --- Build Method Principal ---
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 3. MONEDERO AMBIENTAL (MODIFICADO) ---
                    _buildSectionTitle('Monedero ambiental'),
                    _buildEcoCoinsCard(), // Esta tarjeta invita a invertir

                    // --- Tarjeta de Inversiones ---
                    _buildInvestedCoinsCard(), // Esta muestra lo que tienes
                    
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

  // Widget para el saldo fijo y botones (Sin cambios)
  Widget _buildFixedBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      color: AppColors.darkBlue, 
      child: SafeArea(
        bottom: false,
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
            Text(
              '\$${_saldoDisponible.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAmountDialog(isDepositing: true),
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
                    onPressed: () => _showAmountDialog(isDepositing: false),
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

  // Helper para títulos de sección (sin cambios)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12.0),
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

  // Tarjeta de Monedas (MODIFICADA)
  Widget _buildEcoCoinsCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.eco, color: AppColors.cyan, size: 40),
        title: const Text('Invertir en Monedero', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Usa tu saldo para comprar monedas'), // Texto actualizado
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.greyText),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        onTap: _showInvestmentModal, // Muestra el modal para invertir
      ),
    );
  }

  // Tarjeta de Monedas Invertidas (MODIFICADA)
  Widget _buildInvestedCoinsCard() {
    return Card(
      color: AppColors.darkestBlue, 
      child: ListTile(
        leading: const Icon(Icons.inventory, color: AppColors.lightCyan, size: 40),
        title: const Text('Mis monedas invertidas', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
        // Usa la variable de estado _monedasInvertidas
        subtitle: Text('$_monedasInvertidas monedas', style: const TextStyle(color: AppColors.paleBlue)),
        trailing: const Icon(Icons.lock, size: 16, color: AppColors.greyText),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        //onTap: _showInvestmentModal, // También abre el modal para gestionar
      ),
    );
  }

  // Tarjeta de Aporte (sin cambios)
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


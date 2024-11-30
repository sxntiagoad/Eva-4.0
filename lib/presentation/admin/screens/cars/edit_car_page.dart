import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/models/car.dart';
import 'package:eva/providers/car_provider.dart';
import 'package:intl/intl.dart';

class EditCarPage extends ConsumerStatefulWidget {
  final String carId;

  const EditCarPage({super.key, required this.carId});

  @override
  _EditCarPageState createState() => _EditCarPageState();
}

class _EditCarPageState extends ConsumerState<EditCarPage> {
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadCar();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadCar() async {
    if (_isDisposed) return;
    // Clear any previously loaded car data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        ref.read(selectedCarProvider.notifier).setCar(null);
      }
    });
    
    final carDoc = await FirebaseFirestore.instance.collection('cars').doc(widget.carId).get();
    if (carDoc.exists && !_isDisposed) {
      final car = Car.fromMap(carDoc.data()!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          ref.read(selectedCarProvider.notifier).setCar(car);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carAsyncValue = ref.watch(selectedCarProvider);
    final carNotifier = ref.read(selectedCarProvider.notifier);

    if (carAsyncValue == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${carAsyncValue.brand} ${carAsyncValue.model}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Vehículo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: carAsyncValue.brand,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        onChanged: (value) => carNotifier.updateField('brand', value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: carAsyncValue.model,
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        onChanged: (value) => carNotifier.updateField('model', value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: carAsyncValue.carPlate,
                        decoration: const InputDecoration(
                          labelText: 'Placa',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pin),
                        ),
                        onChanged: (value) => carNotifier.updateField('carPlate', value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: carAsyncValue.carType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Carro',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        onChanged: (value) => carNotifier.updateField('carType', value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Documentación y Mantenimiento',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildDateButton('extracto', 'Extracto', Icons.description, carAsyncValue.extracto),
                      _buildDateButton('soat', 'SOAT', Icons.security, carAsyncValue.soat),
                      _buildDateButton('tarjetaOp', 'Tarjeta de Operación', Icons.credit_card, carAsyncValue.tarjetaOp),
                      _buildDateButton('tecnicoMec', 'Técnico Mecánica', Icons.build, carAsyncValue.tecnicoMec),
                      _buildDateButton('ultCambioAceite', 'Último Cambio de Aceite', Icons.oil_barrel, carAsyncValue.ultCambioAceite),
                      _buildDateButton('proxCambioAceite', 'Próximo Cambio de Aceite', Icons.update, carAsyncValue.proxCambioAceite),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _submitForm(context, ref, widget.carId),
                icon: const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(String field, String label, IconData icon, Timestamp? currentValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton.icon(
        onPressed: () => _selectDate(context, field, currentValue),
        icon: Icon(icon),
        label: Text(
          currentValue != null
              ? '$label: ${DateFormat('dd/MM/yyyy').format(currentValue.toDate())}'
              : 'Seleccionar Fecha de $label',
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.centerLeft,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, String field, Timestamp? currentValue) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentValue?.toDate() ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ref.read(selectedCarProvider.notifier).updateField(field, Timestamp.fromDate(picked));
    }
  }

  void _submitForm(BuildContext context, WidgetRef ref, String carId) {
    if (_isDisposed) return;
    final car = ref.read(selectedCarProvider);
    if (car != null) {
      FirebaseFirestore.instance
          .collection('cars')
          .doc(carId)
          .update(car.toMap())
          .then((_) {
        if (!_isDisposed) {
          ref.invalidate(mapCarsProvider);
          Navigator.pop(context);
        }
      });
    }
  }
}
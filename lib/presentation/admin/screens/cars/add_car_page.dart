import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/models/car.dart';
import 'package:eva/providers/car_provider.dart';

class AddCarPage extends ConsumerStatefulWidget {
  const AddCarPage({super.key});

  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends ConsumerState<AddCarPage> {
  late Car newCar;

  @override
  void initState() {
    super.initState();
    newCar = Car(
      extracto: null,
      soat: null,
      tarjetaOp: null,
      tecnicoMec: null,
      brand: '',
      carPlate: '',
      carType: '',
      model: '',
      ultCambioAceite: null,
      proxCambioAceite: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nuevo Carro'),
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
                        'Información Básica',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        onChanged: (value) => setState(() => newCar = newCar.copyWith(brand: value)),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        onChanged: (value) => setState(() => newCar = newCar.copyWith(model: value)),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Placa'),
                        onChanged: (value) => setState(() => newCar = newCar.copyWith(carPlate: value)),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Tipo de Carro'),
                        onChanged: (value) => setState(() => newCar = newCar.copyWith(carType: value)),
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
                        'Fechas Importantes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildDateButton(
                        icon: Icons.description,
                        label: 'Extracto',
                        date: newCar.extracto,
                        onPressed: () => _selectDate(context, 'extracto'),
                      ),
                      _buildDateButton(
                        icon: Icons.security,
                        label: 'SOAT',
                        date: newCar.soat,
                        onPressed: () => _selectDate(context, 'soat'),
                      ),
                      _buildDateButton(
                        icon: Icons.credit_card,
                        label: 'Tarjeta de Operación',
                        date: newCar.tarjetaOp,
                        onPressed: () => _selectDate(context, 'tarjetaOp'),
                      ),
                      _buildDateButton(
                        icon: Icons.build,
                        label: 'Técnico Mecánica',
                        date: newCar.tecnicoMec,
                        onPressed: () => _selectDate(context, 'tecnicoMec'),
                      ),
                      _buildDateButton(
                        icon: Icons.oil_barrel,
                        label: 'Último Cambio de Aceite',
                        date: newCar.ultCambioAceite,
                        onPressed: () => _selectDate(context, 'ultCambioAceite'),
                      ),
                      _buildDateButton(
                        icon: Icons.oil_barrel,
                        label: 'Próximo Cambio de Aceite',
                        date: newCar.proxCambioAceite,
                        onPressed: () => _selectDate(context, 'proxCambioAceite'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Carro'),
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

  Widget _buildDateButton({
    required IconData icon,
    required String label,
    required Timestamp? date,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          date != null ? '$label: ${date.toDate().toLocal()}' : 'Seleccionar $label',
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

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        switch (field) {
          case 'extracto':
            newCar = newCar.copyWith(extracto: Timestamp.fromDate(picked));
            break;
          case 'soat':
            newCar = newCar.copyWith(soat: Timestamp.fromDate(picked));
            break;
          case 'tarjetaOp':
            newCar = newCar.copyWith(tarjetaOp: Timestamp.fromDate(picked));
            break;
          case 'tecnicoMec':
            newCar = newCar.copyWith(tecnicoMec: Timestamp.fromDate(picked));
            break;
          case 'ultCambioAceite':
            newCar = newCar.copyWith(ultCambioAceite: Timestamp.fromDate(picked));
            break;
          case 'proxCambioAceite':
            newCar = newCar.copyWith(proxCambioAceite: Timestamp.fromDate(picked));
            break;
        }
      });
    }
  }

  void _submitForm() {
    FirebaseFirestore.instance.collection('cars').add(newCar.toMap()).then((_) {
      ref.invalidate(mapCarsProvider);
      Navigator.pop(context);
    });
  }
}
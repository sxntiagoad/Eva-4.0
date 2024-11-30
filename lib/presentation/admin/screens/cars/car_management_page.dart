import 'package:eva/models/car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva/providers/car_provider.dart';
import 'add_car_page.dart';
import 'edit_car_page.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class CarManagementPage extends ConsumerWidget {
  static const String name = 'car-management';
  const CarManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCars = ref.watch(selectedCarsProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Gestión de Carros'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          if (selectedCars.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await deleteSelectedCars(ref);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Carros eliminados')),
                  );
                },
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32.0 : 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vehículos Registrados',
                          style: TextStyle(
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddCarPage()),
                              ).then((_) {
                                ref.invalidate(mapCarsProvider);
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Nuevo Vehículo',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) => ref
                          .read(searchQueryProvider.notifier)
                          .update((state) => value),
                      decoration: InputDecoration(
                        hintText: 'Buscar por placa...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    child: _CarGrid(isDesktop: isDesktop),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CarGrid extends ConsumerWidget {
  final bool isDesktop;

  const _CarGrid({required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('cars').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allCars = snapshot.data?.docs ?? [];
        final filteredCars = allCars.where((doc) {
          final carData = doc.data() as Map<String, dynamic>;
          final car = Car.fromMap(carData);
          return car.carPlate.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return GridView.builder(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getGridCrossAxisCount(MediaQuery.of(context).size.width),
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filteredCars.length,
          itemBuilder: (context, index) => _CarCard(
            carDoc: filteredCars[index],
            isDesktop: isDesktop,
          ),
        );
      },
    );
  }

  int _getGridCrossAxisCount(double width) {
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 700) return 2;
    return 1;
  }
}

class _CarCard extends ConsumerWidget {
  final QueryDocumentSnapshot carDoc;
  final bool isDesktop;

  const _CarCard({
    required this.carDoc,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carId = carDoc.id;
    final carData = carDoc.data() as Map<String, dynamic>;
    final car = Car.fromMap(carData);
    final selectedCars = ref.watch(selectedCarsProvider);
    final isSelected = selectedCars.contains(carId);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue[700]! : Colors.grey[200]!,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCarPage(carId: carId),
            ),
          ).then((_) {
            ref.invalidate(mapCarsProvider);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.brand,
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          car.model,
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _SelectionCheckbox(
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(selectedCarsProvider.notifier).toggleSelection(carId);
                    },
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  car.carPlate,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 16 : 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                car.carType,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionCheckbox extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCheckbox({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? Colors.blue[700] : Colors.grey[400],
        size: 24,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lesson72/models/tour.dart';
import 'package:lesson72/services/firestore_firebase_service.dart';
import 'package:lesson72/views/screens/edit_add_tour.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirestoreFirebaseService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("HOME SCREEN"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: firebaseService.getTours(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("Error"),
            );
          }

          final tours = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = Tour(
                id: tours[index].id,
                title: tours[index]['title'],
                location: tours[index]['location'],
                imageUrl: tours[index]['imageUrl'],
              );
              return Card(
                child: Column(
                  children: [
                    FadeInImage(
                      placeholder: const AssetImage('assets/loading.gif'),
                      image: NetworkImage(tour.imageUrl),
                      height: 150,
                      width: double.infinity,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tour.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                final editedTour = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditAddTour(tour: tour),
                                  ),
                                );

                                await firebaseService.editTour(editedTour);
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await firebaseService.deleteTour(tour.id);
                                // setState(() {});
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Text(
                      tour.location,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final tour = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditAddTour(),
            ),
          );
          await firebaseService.addTour(tour);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

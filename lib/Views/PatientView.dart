import 'package:flutter/material.dart';
import '../models/Doctor.dart';
import '../controllers/Doctor_controller.dart';

class PatientView extends StatefulWidget {
  const PatientView({super.key});

  @override
  State<PatientView> createState() => _PatientViewState();
}

class _PatientViewState extends State<PatientView> {
  final DoctorController controller = DoctorController();

  List<Doctor> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDoctors();
  }

  /// LOAD DATA
  void loadDoctors() async {
    var data = await controller.getDoctors();
    setState(() {
      doctors = data;
      isLoading = false;
    });
  }

  /// SEARCH
  void onSearchTap(String value) async {
    var data = await controller.searchDoctor(value);

    setState(() {
      doctors = data;
    });
  }

  void onQuickAction(String action) {
    print("Clicked: $action");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Welcome back,",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 5),
                    const Text("Hi Thức",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    /// SEARCH
                    TextField(
                      onChanged: (value) {
                        onSearchTap(value); // gọi controller
                      },
                      decoration: InputDecoration(
                        hintText: "Search doctors or clinics...",
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// QUICK ACTIONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Quick Actions",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        buildAction(
                            "AI Diagnosis", Colors.purple, Icons.smart_toy),
                        buildAction("Book Appointment", Colors.blue,
                            Icons.calendar_today),
                        buildAction("My Prescriptions", Colors.green,
                            Icons.description),
                        buildAction(
                            "Chat with Doctor", Colors.teal, Icons.chat),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// UPCOMING APPOINTMENT (giữ nguyên demo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Upcoming Appointment",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              CircleAvatar(
                                radius: 25,
                                child: Icon(Icons.person),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Dr. Michael Chen",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Neurologist"),
                                  Text("10:30 AM - March 15",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text("View Details"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 40),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// TOP DOCTORS (DÙNG FIREBASE)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Top Rated Doctors",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 200,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : doctors.isEmpty
                          ? const Center(
                        child: Text(
                          "No doctors found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];
                          return buildDoctor(doctor);
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// QUICK ACTION
  Widget buildAction(String title, Color color, IconData icon) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(height: 10),
          Text(title, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  ///DOCTOR CARD (MODEL)
  Widget buildDoctor(Doctor doctor) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          print("Click: ${doctor.fullName}");
          // 👉 có thể Navigator sang trang chi tiết
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// AVATAR
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: doctor.avatarUrl.isNotEmpty
                  ? Image.network(
                doctor.avatarUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 40),
              ),
            ),

            /// INFO
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialty,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),

                  /// EXPERIENCE
                  Text(
                    "${doctor.experienceYears} years exp",
                    style: const TextStyle(
                        fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
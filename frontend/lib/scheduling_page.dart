import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchedulingPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  SchedulingPage({this.user});

  @override
  _SchedulingPageState createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  List<dynamic> appointments = [];
  bool isLoading = true;
  Map<String, dynamic>? cabinetInfo;
  String viewMode = 'today'; // 'today' or 'week'
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchCabinetInfo();
  }

  Future<void> _fetchCabinetInfo() async {
    if (widget.user == null || widget.user!['cabinetId'] == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final cabinetId = widget.user!['cabinetId'].toString();
      final response = await http.get(
        Uri.parse('http://localhost:3000/cabinets/$cabinetId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          cabinetInfo = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching cabinet info: $e');
    }

    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    if (widget.user == null || widget.user!['cabinetId'] == null) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      final cabinetId = widget.user!['cabinetId'].toString();
      
      DateTime startDate, endDate;
      
      if (viewMode == 'today') {
        startDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        endDate = startDate.add(Duration(days: 1));
      } else {
        startDate = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
        endDate = startDate.add(Duration(days: 7));
      }

      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/appointments/cabinet/$cabinetId?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          appointments = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showErrorSnackBar('Nu s-au putut încărca programările');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Eroare la încărcarea programărilor');
      print('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, size: 26),
                const SizedBox(width: 10),
                Text(
                  'Programări',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            if (cabinetInfo != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  cabinetInfo!['name'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0097A7),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: _fetchAppointments,
            tooltip: 'Reîmprospătează',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0097A7)),
              ),
            )
          : Column(
              children: [
                _buildFilters(),
                const SizedBox(height: 8),
                _buildStats(),
                const SizedBox(height: 16),
                Expanded(child: _buildAppointmentsList()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewAppointmentDialog(),
        backgroundColor: const Color(0xFF0097A7),
        icon: Icon(Icons.add),
        label: Text('Programare Nouă'),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildViewModeButton('Astăzi', 'today', Icons.today_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildViewModeButton('Săptămâna', 'week', Icons.date_range_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: Color(0xFF0097A7)),
                onPressed: () {
                  setState(() {
                    selectedDate = viewMode == 'today'
                        ? selectedDate.subtract(Duration(days: 1))
                        : selectedDate.subtract(Duration(days: 7));
                  });
                  _fetchAppointments();
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    viewMode == 'today'
                        ? DateFormat('d MMMM yyyy', 'ro').format(selectedDate)
                        : 'Săptămâna ${_getWeekNumber(selectedDate)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0097A7),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: Color(0xFF0097A7)),
                onPressed: () {
                  setState(() {
                    selectedDate = viewMode == 'today'
                        ? selectedDate.add(Duration(days: 1))
                        : selectedDate.add(Duration(days: 7));
                  });
                  _fetchAppointments();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(String label, String mode, IconData icon) {
    final isSelected = viewMode == mode;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          viewMode = mode;
          if (mode == 'today') {
            selectedDate = DateTime.now();
          }
        });
        _fetchAppointments();
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF0097A7) : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStartOfYear = date.difference(startOfYear).inDays;
    return (daysSinceStartOfYear / 7).ceil() + 1;
  }

  Widget _buildStats() {
    final filteredAppointments = appointments.where((a) => a['type'] != 'blocked').toList();
    final totalCount = filteredAppointments.length;
    final confirmedCount = filteredAppointments.where((a) => a['status'] == 'confirmed').length;
    final scheduledCount = filteredAppointments.where((a) => a['status'] == 'scheduled').length;
    final completedCount = filteredAppointments.where((a) => a['status'] == 'completed').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total', totalCount.toString(), Icons.event, Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Confirmate', confirmedCount.toString(), Icons.check_circle, Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Programate', scheduledCount.toString(), Icons.schedule, Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Finalizate', completedCount.toString(), Icons.done_all, Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0097A7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 60,
                color: const Color(0xFF0097A7).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nicio programare',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewMode == 'today'
                  ? DateFormat('d MMMM yyyy', 'ro').format(selectedDate)
                  : 'Săptămâna ${_getWeekNumber(selectedDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Group appointments by date
    final groupedAppointments = <String, List<dynamic>>{};
    for (var appointment in appointments) {
      final startTime = DateTime.parse(appointment['startTime']);
      final dateKey = DateFormat('yyyy-MM-dd').format(startTime);
      
      if (!groupedAppointments.containsKey(dateKey)) {
        groupedAppointments[dateKey] = [];
      }
      groupedAppointments[dateKey]!.add(appointment);
    }

    final sortedKeys = groupedAppointments.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final dayAppointments = groupedAppointments[dateKey]!;
        final date = DateTime.parse(dateKey);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(0xFF0097A7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'ro').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0097A7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF0097A7).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${dayAppointments.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0097A7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...dayAppointments.map((appointment) => _buildAppointmentCard(appointment)).toList(),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    final startTime = DateTime.parse(appointment['startTime']);
    final endTime = DateTime.parse(appointment['endTime']);
    final isBlocked = appointment['type'] == 'blocked';
    final color = isBlocked ? Colors.red : _getStatusColor(appointment['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showAppointmentDetails(appointment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(startTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(endTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isBlocked ? Icons.block_rounded : Icons.event_rounded,
                          size: 18,
                          color: color,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            appointment['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isBlocked) ...[
                      const SizedBox(height: 6),
                      if (appointment['clientName'] != null)
                        Row(
                          children: [
                            Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              appointment['clientName'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      if (appointment['clientPhone'] != null)
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              appointment['clientPhone'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isBlocked ? 'BLOCAT' : _getStatusLabel(appointment['status']),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'scheduled':
        return 'PROGRAMAT';
      case 'confirmed':
        return 'CONFIRMAT';
      case 'completed':
        return 'FINALIZAT';
      case 'cancelled':
        return 'ANULAT';
      default:
        return status.toUpperCase();
    }
  }

  void _showAppointmentDetails(dynamic appointment) {
    final startTime = DateTime.parse(appointment['startTime']);
    final endTime = DateTime.parse(appointment['endTime']);
    final isBlocked = appointment['type'] == 'blocked';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isBlocked ? Icons.block_rounded : Icons.event_rounded,
              color: isBlocked ? Colors.red : Color(0xFF0097A7),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                appointment['title'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                Icons.calendar_today,
                'Data',
                DateFormat('d MMMM yyyy', 'ro').format(startTime),
              ),
              _buildDetailRow(
                Icons.access_time,
                'Interval',
                '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
              ),
              if (!isBlocked) ...[
                _buildDetailRow(
                  Icons.info_outline,
                  'Status',
                  _getStatusLabel(appointment['status']),
                ),
                if (appointment['clientName'] != null)
                  _buildDetailRow(Icons.person, 'Client', appointment['clientName']),
                if (appointment['clientPhone'] != null)
                  _buildDetailRow(Icons.phone, 'Telefon', appointment['clientPhone']),
                if (appointment['clientEmail'] != null)
                  _buildDetailRow(Icons.email, 'Email', appointment['clientEmail']),
                if (appointment['reason'] != null)
                  _buildDetailRow(Icons.description, 'Motiv', appointment['reason']),
              ],
              if (appointment['notes'] != null)
                _buildDetailRow(Icons.note, 'Notițe', appointment['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Închide'),
          ),
          if (!isBlocked && appointment['status'] != 'completed')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditAppointmentDialog(appointment);
              },
              child: Text('Editează'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(appointment['id']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Șterge'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNewAppointmentDialog() {
    final titleController = TextEditingController();
    final clientNameController = TextEditingController();
    final clientPhoneController = TextEditingController();
    final clientEmailController = TextEditingController();
    final reasonController = TextEditingController();
    final notesController = TextEditingController();
    
    DateTime selectedAppDate = selectedDate;
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.event_available_rounded, color: Color(0xFF0097A7)),
              const SizedBox(width: 8),
              Text('Programare Nouă'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Titlu*',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clientNameController,
                  decoration: InputDecoration(
                    labelText: 'Nume Client*',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clientPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefon*',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clientEmailController,
                  decoration: InputDecoration(
                    labelText: 'Email (opțional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.calendar_today),
                  title: Text('Data'),
                  subtitle: Text(DateFormat('d MMMM yyyy', 'ro').format(selectedAppDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedAppDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedAppDate = date);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.access_time),
                  title: Text('Ora start'),
                  subtitle: Text(startTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (time != null) {
                      setDialogState(() => startTime = time);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.access_time),
                  title: Text('Ora sfârșit'),
                  subtitle: Text(endTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (time != null) {
                      setDialogState(() => endTime = time);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'Motiv',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notițe',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    clientNameController.text.isEmpty ||
                    clientPhoneController.text.isEmpty) {
                  _showErrorSnackBar('Completați câmpurile obligatorii');
                  return;
                }

                final startDateTime = DateTime(
                  selectedAppDate.year,
                  selectedAppDate.month,
                  selectedAppDate.day,
                  startTime.hour,
                  startTime.minute,
                );

                final endDateTime = DateTime(
                  selectedAppDate.year,
                  selectedAppDate.month,
                  selectedAppDate.day,
                  endTime.hour,
                  endTime.minute,
                );

                Navigator.pop(context);
                _createAppointment(
                  title: titleController.text,
                  startTime: startDateTime,
                  endTime: endDateTime,
                  clientName: clientNameController.text,
                  clientPhone: clientPhoneController.text,
                  clientEmail: clientEmailController.text.isNotEmpty
                      ? clientEmailController.text
                      : null,
                  reason: reasonController.text.isNotEmpty ? reasonController.text : null,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0097A7),
                foregroundColor: Colors.white,
              ),
              child: Text('Salvează'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAppointmentDialog(dynamic appointment) {
    final titleController = TextEditingController(text: appointment['title']);
    final clientNameController = TextEditingController(text: appointment['clientName']);
    final clientPhoneController = TextEditingController(text: appointment['clientPhone']);
    final clientEmailController = TextEditingController(text: appointment['clientEmail'] ?? '');
    final reasonController = TextEditingController(text: appointment['reason'] ?? '');
    final notesController = TextEditingController(text: appointment['notes'] ?? '');
    
    final startDateTime = DateTime.parse(appointment['startTime']);
    final endDateTime = DateTime.parse(appointment['endTime']);
    
    DateTime selectedAppDate = startDateTime;
    TimeOfDay startTime = TimeOfDay.fromDateTime(startDateTime);
    TimeOfDay endTime = TimeOfDay.fromDateTime(endDateTime);
    String selectedStatus = appointment['status'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.edit_rounded, color: Color(0xFF0097A7)),
              const SizedBox(width: 8),
              Text('Editare Programare'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Titlu*',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.info),
                  ),
                  items: [
                    DropdownMenuItem(value: 'scheduled', child: Text('Programat')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmat')),
                    DropdownMenuItem(value: 'completed', child: Text('Finalizat')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Anulat')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clientNameController,
                  decoration: InputDecoration(
                    labelText: 'Nume Client*',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clientPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefon*',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clientEmailController,
                  decoration: InputDecoration(
                    labelText: 'Email (opțional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.calendar_today),
                  title: Text('Data'),
                  subtitle: Text(DateFormat('d MMMM yyyy', 'ro').format(selectedAppDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedAppDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedAppDate = date);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.access_time),
                  title: Text('Ora start'),
                  subtitle: Text(startTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (time != null) {
                      setDialogState(() => startTime = time);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.access_time),
                  title: Text('Ora sfârșit'),
                  subtitle: Text(endTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (time != null) {
                      setDialogState(() => endTime = time);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'Motiv',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notițe',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    clientNameController.text.isEmpty ||
                    clientPhoneController.text.isEmpty) {
                  _showErrorSnackBar('Completați câmpurile obligatorii');
                  return;
                }

                final newStartDateTime = DateTime(
                  selectedAppDate.year,
                  selectedAppDate.month,
                  selectedAppDate.day,
                  startTime.hour,
                  startTime.minute,
                );

                final newEndDateTime = DateTime(
                  selectedAppDate.year,
                  selectedAppDate.month,
                  selectedAppDate.day,
                  endTime.hour,
                  endTime.minute,
                );

                Navigator.pop(context);
                _updateAppointment(
                  appointmentId: appointment['id'],
                  title: titleController.text,
                  startTime: newStartDateTime,
                  endTime: newEndDateTime,
                  status: selectedStatus,
                  clientName: clientNameController.text,
                  clientPhone: clientPhoneController.text,
                  clientEmail: clientEmailController.text.isNotEmpty
                      ? clientEmailController.text
                      : null,
                  reason: reasonController.text.isNotEmpty ? reasonController.text : null,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0097A7),
                foregroundColor: Colors.white,
              ),
              child: Text('Actualizează'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAppointment({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String clientName,
    required String clientPhone,
    String? clientEmail,
    String? reason,
    String? notes,
  }) async {
    print('📤 CREATING APPOINTMENT (Scheduling):');
    print('  Title: $title');
    print('  Start: ${startTime.toIso8601String()}');
    print('  End: ${endTime.toIso8601String()}');
    print('  Client: $clientName ($clientPhone)');
    print('  CabinetId: ${widget.user!['cabinetId']}');

    final requestBody = {
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': 'appointment',
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'reason': reason,
      'notes': notes,
      'cabinetId': widget.user!['cabinetId'],
      'createdBy': widget.user!['id'],
    };

    print('📦 Request Body: $requestBody');

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        _showSuccessSnackBar('Programare creată cu succes');
        _fetchAppointments();
      } else {
        final error = jsonDecode(response.body);
        print('❌ Error from server: $error');
        _showErrorSnackBar(error['message'] ?? 'Eroare la creare');
      }
    } catch (e) {
      print('❌ Exception caught: $e');
      _showErrorSnackBar('Eroare de conexiune: $e');
    }
  }

  Future<void> _updateAppointment({
    required int appointmentId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String status,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? reason,
    String? notes,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/appointments/$appointmentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'status': status,
          'clientName': clientName,
          'clientPhone': clientPhone,
          'clientEmail': clientEmail,
          'reason': reason,
          'notes': notes,
          'updatedBy': widget.user!['id'],
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Programare actualizată cu succes');
        _fetchAppointments();
      } else {
        final error = jsonDecode(response.body);
        _showErrorSnackBar(error['message'] ?? 'Eroare la actualizare');
      }
    } catch (e) {
      _showErrorSnackBar('Eroare de conexiune');
      print('Error: $e');
    }
  }

  Future<void> _deleteAppointment(int appointmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmare'),
        content: Text('Sigur doriți să ștergeți această programare?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Anulează'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Șterge'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/appointments/$appointmentId'),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Programare ștearsă cu succes');
        _fetchAppointments();
      } else {
        _showErrorSnackBar('Eroare la ștergere');
      }
    } catch (e) {
      _showErrorSnackBar('Eroare de conexiune');
      print('Error: $e');
    }
  }
}

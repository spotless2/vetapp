import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'config/api_config.dart';

class CalendarPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  CalendarPage({this.user});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> appointments = [];
  bool isLoading = true;
  Map<String, dynamic>? cabinetInfo;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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
        Uri.parse('${ApiConfig.baseUrl}/cabinets/$cabinetId'),
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
      
      // Calculate date range based on calendar format
      DateTime startDate, endDate;
      
      if (_calendarFormat == CalendarFormat.week) {
        startDate = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
        endDate = startDate.add(Duration(days: 6));
      } else if (_calendarFormat == CalendarFormat.twoWeeks) {
        startDate = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
        endDate = startDate.add(Duration(days: 13));
      } else {
        startDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
        endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/appointments/cabinet/$cabinetId?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}',
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

  List<dynamic> _getAppointmentsForDay(DateTime day) {
    return appointments.where((appointment) {
      final startTime = DateTime.parse(appointment['startTime']);
      return startTime.year == day.year &&
          startTime.month == day.month &&
          startTime.day == day.day;
    }).toList();
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 26),
            const SizedBox(width: 10),
            Text(
              cabinetInfo != null ? cabinetInfo!['name'] : 'Calendar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF7B1FA2),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          PopupMenuButton<CalendarFormat>(
            icon: Icon(Icons.view_module_rounded),
            onSelected: (format) {
              setState(() {
                _calendarFormat = format;
              });
              _fetchAppointments();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: CalendarFormat.month,
                child: Row(
                  children: [
                    Icon(Icons.calendar_view_month, size: 20),
                    SizedBox(width: 8),
                    Text('Lună'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: CalendarFormat.twoWeeks,
                child: Row(
                  children: [
                    Icon(Icons.view_week, size: 20),
                    SizedBox(width: 8),
                    Text('2 Săptămâni'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: CalendarFormat.week,
                child: Row(
                  children: [
                    Icon(Icons.view_day, size: 20),
                    SizedBox(width: 8),
                    Text('Săptămână'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B1FA2)),
              ),
            )
          : Column(
              children: [
                _buildCalendar(),
                const SizedBox(height: 16),
                _buildQuickActions(),
                const SizedBox(height: 16),
                Expanded(child: _buildAppointmentsList()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewAppointmentDialog(),
        backgroundColor: const Color(0xFF7B1FA2),
        icon: Icon(Icons.add),
        label: Text('Programare'),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
          _fetchAppointments();
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _fetchAppointments();
        },
        eventLoader: _getAppointmentsForDay,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFF7B1FA2).withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: const Color(0xFF7B1FA2),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: const Color(0xFFE91E63),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: Colors.red.shade400),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF7B1FA2),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              'Programare Nouă',
              Icons.event_available_rounded,
              const Color(0xFF7B1FA2),
              () => _showNewAppointmentDialog(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              'Blochează Slot',
              Icons.block_rounded,
              const Color(0xFFE64A19),
              () => _showBlockSlotDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final dayAppointments = _getAppointmentsForDay(_selectedDay!);

    if (dayAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF7B1FA2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 60,
                color: const Color(0xFF7B1FA2).withOpacity(0.5),
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
              DateFormat('d MMMM yyyy', 'ro').format(_selectedDay!),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dayAppointments.length,
      itemBuilder: (context, index) {
        final appointment = dayAppointments[index];
        return _buildAppointmentCard(appointment);
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
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (!isBlocked && appointment['clientName'] != null) ...[
                      const SizedBox(height: 4),
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
              color: isBlocked ? Colors.red : Color(0xFF7B1FA2),
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
    
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.event_available_rounded, color: Color(0xFF7B1FA2)),
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
                  subtitle: Text(DateFormat('d MMMM yyyy', 'ro').format(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
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
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  startTime.hour,
                  startTime.minute,
                );

                final endDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
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
                  type: 'appointment',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7B1FA2),
                foregroundColor: Colors.white,
              ),
              child: Text('Salvează'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockSlotDialog() {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.block_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Text('Blochează Slot'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Motiv Blocare*',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.calendar_today),
                  title: Text('Data'),
                  subtitle: Text(DateFormat('d MMMM yyyy', 'ro').format(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
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
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Detalii',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
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
                if (titleController.text.isEmpty) {
                  _showErrorSnackBar('Introduceți motivul blocării');
                  return;
                }

                final startDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  startTime.hour,
                  startTime.minute,
                );

                final endDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  endTime.hour,
                  endTime.minute,
                );

                Navigator.pop(context);
                _createAppointment(
                  title: titleController.text,
                  startTime: startDateTime,
                  endTime: endDateTime,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                  type: 'blocked',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Blochează'),
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
    
    DateTime selectedDate = startDateTime;
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
              Icon(Icons.edit_rounded, color: Color(0xFF7B1FA2)),
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
                  subtitle: Text(DateFormat('d MMMM yyyy', 'ro').format(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
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
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  startTime.hour,
                  startTime.minute,
                );

                final newEndDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
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
                backgroundColor: Color(0xFF7B1FA2),
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
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? reason,
    String? notes,
    required String type,
  }) async {
    print('📤 CREATING APPOINTMENT:');
    print('  Title: $title');
    print('  Type: $type');
    print('  Start: ${startTime.toIso8601String()}');
    print('  End: ${endTime.toIso8601String()}');
    print('  CabinetId: ${widget.user!['cabinetId']}');
    print('  CreatedBy: ${widget.user!['id']}');

    final requestBody = {
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type,
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
        Uri.parse('${ApiConfig.baseUrl}/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        _showSuccessSnackBar(
          type == 'blocked' ? 'Slot blocat cu succes' : 'Programare creată cu succes',
        );
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
        Uri.parse('${ApiConfig.baseUrl}/appointments/$appointmentId'),
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
        Uri.parse('${ApiConfig.baseUrl}/appointments/$appointmentId'),
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

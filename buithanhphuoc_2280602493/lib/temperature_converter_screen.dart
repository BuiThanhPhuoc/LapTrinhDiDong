import 'package:flutter/material.dart';

class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() =>
      _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen> {
  final TextEditingController _controller = TextEditingController();
  
  // Biến lưu kết quả
  String _resultValue = '';
  
  // Đơn vị mặc định
  String _inputUnit = 'Celsius';
  String _outputUnit = 'Fahrenheit';

  final List<String> _units = ['Celsius', 'Fahrenheit', 'Kelvin'];

  // Map ký hiệu
  final Map<String, String> _unitSymbols = {
    'Celsius': '°C',
    'Fahrenheit': '°F',
    'Kelvin': 'K',
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Logic chuyển đổi
  void _calculate() {
    if (_controller.text.isEmpty) {
      setState(() => _resultValue = '');
      return;
    }

    double? input = double.tryParse(_controller.text.replaceAll(',', '.'));
    
    if (input == null) {
      setState(() => _resultValue = 'Lỗi');
      return;
    }

    double tempInCelsius;

    // 1. Chuyển về Celsius
    if (_inputUnit == 'Celsius') {
      tempInCelsius = input;
    } else if (_inputUnit == 'Fahrenheit') {
      tempInCelsius = (input - 32) * 5 / 9;
    } else {
      tempInCelsius = input - 273.15;
    }

    // 2. Chuyển từ Celsius sang đích
    double result;
    if (_outputUnit == 'Celsius') {
      result = tempInCelsius;
    } else if (_outputUnit == 'Fahrenheit') {
      result = tempInCelsius * 9 / 5 + 32;
    } else {
      result = tempInCelsius + 273.15;
    }

    // Làm đẹp số (bỏ số 0 thừa ở cuối: 25.00 -> 25)
    setState(() {
      _resultValue = result.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
    });
  }

  // Đảo ngược đơn vị
  void _swapUnits() {
    setState(() {
      String temp = _inputUnit;
      _inputUnit = _outputUnit;
      _outputUnit = temp;
      _calculate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Ẩn phím khi chạm ra ngoài
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA), // Màu nền xám nhẹ hiện đại
        appBar: AppBar(
          title: const Text('🌡️ Chuyển Đổi Nhiệt Độ'),
          centerTitle: true,
          backgroundColor: Colors.deepOrangeAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              
              // --- CARD GIAO DIỆN CHÍNH ---
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // --- KHU VỰC NHẬP (INPUT) ---
                      _buildLabel('Nhập nhiệt độ'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: InputBorder.none, // Bỏ viền để nhìn thoáng hơn
                                hintStyle: TextStyle(color: Colors.black26),
                              ),
                              onChanged: (_) => _calculate(),
                            ),
                          ),
                          _buildUnitDropdown(
                            value: _inputUnit,
                            onChanged: (val) {
                              setState(() => _inputUnit = val!);
                              _calculate();
                            },
                          ),
                        ],
                      ),
                      
                      const Divider(height: 30, thickness: 1),

                      // --- NÚT SWAP Ở GIỮA ---
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(height: 1, color: Colors.grey.shade200), // Đường kẻ mờ
                          InkWell(
                            onTap: _swapUnits,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.deepOrangeAccent.shade100,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))
                                ]
                              ),
                              child: const Icon(Icons.swap_vert, size: 28, color: Colors.deepOrange),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // --- KHU VỰC KẾT QUẢ (OUTPUT) ---
                      _buildLabel('Kết quả'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _resultValue.isEmpty ? '...' : _resultValue,
                              style: const TextStyle(
                                fontSize: 32, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.deepOrange
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildUnitDropdown(
                            value: _outputUnit,
                            onChanged: (val) {
                              setState(() => _outputUnit = val!);
                              _calculate();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              
              // --- FORMULA (Công thức) ---
              if (_resultValue.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blueGrey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Công thức: ${_getFormulaInfo()}',
                          style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị Label nhỏ
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: Colors.grey.shade500,
          letterSpacing: 1.2
        ),
      ),
    );
  }

  // Widget Dropdown tùy chỉnh
  Widget _buildUnitDropdown({required String value, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          onChanged: onChanged,
          items: _units.map((String unit) {
            return DropdownMenuItem<String>(
              value: unit,
              child: Row(
                children: [
                  Text(unit),
                  const SizedBox(width: 5),
                  Text(
                    '(${_unitSymbols[unit]})',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Hàm trả về text công thức đơn giản để hiển thị
  String _getFormulaInfo() {
    if (_inputUnit == 'Celsius' && _outputUnit == 'Fahrenheit') return '(°C × 9/5) + 32 = °F';
    if (_inputUnit == 'Fahrenheit' && _outputUnit == 'Celsius') return '(°F − 32) × 5/9 = °C';
    if (_inputUnit == 'Celsius' && _outputUnit == 'Kelvin') return '°C + 273.15 = K';
    if (_inputUnit == 'Kelvin' && _outputUnit == 'Celsius') return 'K − 273.15 = °C';
    if (_inputUnit == _outputUnit) return 'Giá trị không đổi';
    return 'Chuyển đổi phức hợp';
  }
}
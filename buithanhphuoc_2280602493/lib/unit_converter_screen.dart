import 'package:flutter/material.dart';

// --- ĐỊNH NGHĨA DỮ LIỆU ---
enum UnitType { length, mass }

class Unit {
  final String name;
  final String symbol;
  final UnitType type;
  final double conversionFactor;

  const Unit(this.name, this.symbol, this.type, this.conversionFactor);
}

// Danh sách đơn vị (Giữ nguyên logic của bạn)
const List<Unit> allUnits = [
  // Độ dài
  Unit('Mét', 'm', UnitType.length, 1.0),
  Unit('Kilômét', 'km', UnitType.length, 1000.0),
  Unit('Centimét', 'cm', UnitType.length, 0.01),
  Unit('Milimét', 'mm', UnitType.length, 0.001),
  Unit('Feet', 'ft', UnitType.length, 0.3048),
  Unit('Inch', 'in', UnitType.length, 0.0254),
  Unit('Dặm', 'mi', UnitType.length, 1609.34),
  
  // Khối lượng
  Unit('Kilôgam', 'kg', UnitType.mass, 1.0),
  Unit('Gam', 'g', UnitType.mass, 0.001),
  Unit('Miligam', 'mg', UnitType.mass, 0.000001),
  Unit('Pound', 'lbs', UnitType.mass, 0.453592),
  Unit('Ounce', 'oz', UnitType.mass, 0.0283495),
];

// --- GIAO DIỆN CHÍNH ---

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final TextEditingController _controller = TextEditingController();
  
  // Trạng thái
  String _resultValue = '';
  UnitType _selectedType = UnitType.length;
  late Unit _fromUnit;
  late Unit _toUnit;

  @override
  void initState() {
    super.initState();
    _resetUnitsForType(UnitType.length);
  }

  // Hàm reset đơn vị khi đổi loại (Length <-> Mass)
  void _resetUnitsForType(UnitType type) {
    final units = allUnits.where((u) => u.type == type).toList();
    _selectedType = type;
    _fromUnit = units.first;
    _toUnit = units.length > 1 ? units[1] : units.first;
    _calculate();
  }

  // Logic chuyển đổi
  void _calculate() {
    if (_controller.text.isEmpty) {
      setState(() => _resultValue = '');
      return;
    }

    // Xử lý dấu phẩy thành dấu chấm để parse
    double? input = double.tryParse(_controller.text.replaceAll(',', '.'));

    if (input == null) {
      setState(() => _resultValue = '...');
      return;
    }

    // Công thức: (Input * Factor_From) / Factor_To
    double baseValue = input * _fromUnit.conversionFactor;
    double result = baseValue / _toUnit.conversionFactor;

    setState(() {
      // Format số: tối đa 6 số thập phân, xóa số 0 thừa
      _resultValue = result
          .toStringAsFixed(6)
          .replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
    });
  }

  // Đảo chiều
  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _calculate();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách đơn vị theo loại đang chọn
    final currentUnits = allUnits.where((u) => u.type == _selectedType).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text('📏 Chuyển Đổi Đơn Vị'),
          centerTitle: true,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. KHU VỰC CHỌN LOẠI (Tab Selector)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Row(
                  children: [
                    _buildTypeTab('Độ Dài', UnitType.length, Icons.straighten),
                    _buildTypeTab('Khối Lượng', UnitType.mass, Icons.scale),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 2. CARD CHUYỂN ĐỔI CHÍNH
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // --- INPUT SECTION ---
                      _buildLabel('Nhập giá trị'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.black12),
                              ),
                              onChanged: (_) => _calculate(),
                            ),
                          ),
                          _buildUnitDropdown(
                            value: _fromUnit,
                            items: currentUnits,
                            onChanged: (val) {
                              setState(() => _fromUnit = val!);
                              _calculate();
                            },
                          ),
                        ],
                      ),

                      const Divider(height: 30, thickness: 1),

                      // --- SWAP BUTTON (Ở giữa) ---
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(height: 1, color: Colors.grey.shade100),
                          InkWell(
                            onTap: _swapUnits,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.teal.shade100),
                              ),
                              child: const Icon(Icons.swap_vert_rounded, size: 28, color: Colors.teal),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // --- OUTPUT SECTION ---
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
                                color: Colors.black87
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildUnitDropdown(
                            value: _toUnit,
                            items: currentUnits,
                            onChanged: (val) {
                              setState(() => _toUnit = val!);
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

              // 3. THÔNG TIN TỈ LỆ (Formula info)
              if (_resultValue.isNotEmpty && _resultValue != '...')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.teal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '1 ${_fromUnit.symbol} = ${(_fromUnit.conversionFactor / _toUnit.conversionFactor).toStringAsFixed(6).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")} ${_toUnit.symbol}',
                          style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.w600),
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

  // Widget Tab chọn loại (Custom Segmented Control)
  Widget _buildTypeTab(String text, UnitType type, IconData icon) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _resetUnitsForType(type);
            _controller.clear();
            _resultValue = '';
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Label nhỏ
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: Colors.grey.shade500,
          letterSpacing: 1.0
        ),
      ),
    );
  }

  // Widget Dropdown tùy chỉnh
  Widget _buildUnitDropdown({
    required Unit value,
    required List<Unit> items,
    required Function(Unit?) onChanged
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Unit>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          onChanged: onChanged,
          items: items.map((Unit unit) {
            return DropdownMenuItem<Unit>(
              value: unit,
              child: Row(
                children: [
                  Text(unit.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(
                    unit.name,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:scout_os_app/features/location/data/location_repository.dart';

class LocationController extends ChangeNotifier {
  final LocationRepository _repo = LocationRepository();

  bool _isLoading = false;
  String? _errorMessage;

  List<LocationOption> _provinsiList = [];
  List<LocationOption> _kabupatenList = [];
  List<LocationOption> _kecamatanList = [];

  LocationOption? _selectedProvinsi;
  LocationOption? _selectedKabupaten;
  LocationOption? _selectedKecamatan;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  List<LocationOption> get provinsiList => _provinsiList;
  List<LocationOption> get kabupatenList => _kabupatenList;
  List<LocationOption> get kecamatanList => _kecamatanList;

  LocationOption? get selectedProvinsi => _selectedProvinsi;
  LocationOption? get selectedKabupaten => _selectedKabupaten;
  LocationOption? get selectedKecamatan => _selectedKecamatan;

  Future<void> fetchProvinsi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _provinsiList = await _repo.getProvinsi();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProvinsi(LocationOption prov) async {
    _selectedProvinsi = prov;
    _selectedKabupaten = null;
    _selectedKecamatan = null;
    _kabupatenList = [];
    _kecamatanList = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kabupatenList = await _repo.getKabupaten(prov.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectKabupaten(LocationOption kab) async {
    _selectedKabupaten = kab;
    _selectedKecamatan = null;
    _kecamatanList = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kecamatanList = await _repo.getKecamatan(kab.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectKecamatan(LocationOption kec) {
    _selectedKecamatan = kec;
    notifyListeners();
  }

  Future<bool> saveLocation() async {
    if (_selectedKecamatan == null) {
      _errorMessage = 'Silakan pilih kecamatan terlebih dahulu.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.setLocation(_selectedKecamatan!.id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

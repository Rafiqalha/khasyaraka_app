import 'package:flutter/material.dart';
import 'package:scout_os_app/features/location/data/location_repository.dart';

class LocationController extends ChangeNotifier {
  final LocationRepository _repo = LocationRepository();

  int _requestVersion = 0;

  bool _isLoading = false;
  String? _errorMessage;

  List<LocationOption> _countryList = [];
  List<LocationOption> _provinsiList = [];
  List<LocationOption> _kabupatenList = [];
  List<LocationOption> _kecamatanList = [];

  LocationOption? _selectedCountry;
  LocationOption? _selectedProvinsi;
  LocationOption? _selectedKabupaten;
  LocationOption? _selectedKecamatan;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<LocationOption> get countryList => _countryList;
  List<LocationOption> get provinsiList => _provinsiList;
  List<LocationOption> get kabupatenList => _kabupatenList;
  List<LocationOption> get kecamatanList => _kecamatanList;

  LocationOption? get selectedCountry => _selectedCountry;
  LocationOption? get selectedProvinsi => _selectedProvinsi;
  LocationOption? get selectedKabupaten => _selectedKabupaten;
  LocationOption? get selectedKecamatan => _selectedKecamatan;

  Future<void> fetchCountries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _countryList = await _repo.getCountries();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCountry(LocationOption country) async {
    _requestVersion++;
    final version = _requestVersion;

    _selectedCountry = country;
    _selectedProvinsi = null;
    _selectedKabupaten = null;
    _selectedKecamatan = null;
    _provinsiList = [];
    _kabupatenList = [];
    _kecamatanList = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final provinces = await _repo.getProvinsi(countryId: country.id);
      if (_requestVersion != version) return;
      _provinsiList = provinces;
      if (_provinsiList.isEmpty) {
        await _repo.updateProfileCountry(country.id);
      }
    } catch (e) {
      if (_requestVersion != version) return;
      _errorMessage = e.toString();
    }

    if (_requestVersion != version) return;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectProvinsi(LocationOption prov) async {
    _requestVersion++;
    final version = _requestVersion;

    _selectedProvinsi = prov;
    _selectedKabupaten = null;
    _selectedKecamatan = null;
    _kabupatenList = [];
    _kecamatanList = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final kabupatens = await _repo.getKabupaten(prov.id);
      if (_requestVersion != version) return;
      _kabupatenList = kabupatens;
    } catch (e) {
      if (_requestVersion != version) return;
      _errorMessage = e.toString();
    }

    if (_requestVersion != version) return;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectKabupaten(LocationOption kab) async {
    _requestVersion++;
    final version = _requestVersion;

    _selectedKabupaten = kab;
    _selectedKecamatan = null;
    _kecamatanList = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final kecamatans = await _repo.getKecamatan(kab.id);
      if (_requestVersion != version) return;
      _kecamatanList = kecamatans;
    } catch (e) {
      if (_requestVersion != version) return;
      _errorMessage = e.toString();
    }

    if (_requestVersion != version) return;
    _isLoading = false;
    notifyListeners();
  }

  void selectKecamatan(LocationOption kec) {
    _selectedKecamatan = kec;
    notifyListeners();
  }

  Future<bool> saveLocation() async {
    if (_selectedKecamatan == null) {
      if (_selectedCountry != null && _provinsiList.isEmpty) {
        return true;
      }
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

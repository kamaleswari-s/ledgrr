// Automatically uses the web implementation when running on web,
// and the stub everywhere else. This means the same downloadCsv()
// call works correctly no matter what platform is running, and
// nothing breaks when you build for Android later.
export 'csv_export_stub.dart'
    if (dart.library.html) 'csv_export_web.dart';
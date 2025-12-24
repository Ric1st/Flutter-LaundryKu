import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://lpgztcrqvhxrmpmhnwaj.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwZ3p0Y3Jxdmh4cm1wbWhud2FqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4OTIyMjksImV4cCI6MjA4MTQ2ODIyOX0.3tLLXH8-hCN8s-5MTfNzG7BofHX6PxHATZfpiNRu5F8';

  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}

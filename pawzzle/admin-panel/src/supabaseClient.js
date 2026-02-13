import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://vexsfgtialxsbftneecj.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZleHNmZ3RpYWx4c2JmdG5lZWNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzUyNTksImV4cCI6MjA3NzQxMTI1OX0.al6xNQUiS3kWm8x2u7E0aB3d-hZNPHAulW7ee1l0_mA';

export const supabase = createClient(supabaseUrl, supabaseKey);

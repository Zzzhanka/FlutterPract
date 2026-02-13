import { supabase } from '../supabaseClient';

// --- Квесты дня ---
export const addDailyQuest = async (title, description, requiredStars, reward) => {
  const { data, error } = await supabase
    .from('daily_quests')
    .insert([{ title, description, required_stars: requiredStars, reward }]);
  if (error) throw error;
  return data;
};

export const getDailyQuests = async () => {
  const { data, error } = await supabase.from('daily_quests').select('*');
  if (error) throw error;
  return data;
};

export const publishQuest = async (questId, publish) => {
  const { data, error } = await supabase
    .from('daily_quests')
    .update({ published: publish })
    .eq('id', questId);
  if (error) throw error;
  return data;
};

// --- Пользователи ---
export const fetchUsers = async () => {
  const { data, error } = await supabase
    .from('users')
    .select('*');
  if (error) throw error;
  return data;
};

import React, { useEffect, useState } from 'react';
import DashboardChart from '../components/DashboardChart';
import { fetchUsers, getDailyQuests } from '../api/adminApi';

const Dashboard = () => {
  const [users, setUsers] = useState([]);
  const [quests, setQuests] = useState([]);
  
  useEffect(() => {
    const loadData = async () => {
      const usersData = await fetchUsers();
      setUsers(usersData);

      const questsData = await getDailyQuests();
      setQuests(questsData);
    };
    loadData();
  }, []);

  // пример данных для графика
  const chartData = [
    { day: 'Mon', completed: quests.length > 0 ? quests[0].required_stars : 0 },
    { day: 'Tue', completed: 10 },
    { day: 'Wed', completed: 7 },
  ];

  return (
    <div>
      <h1>Dashboard</h1>
      <p>Всего пользователей: {users.length}</p>
      <DashboardChart data={chartData} />
    </div>
  );
};

export default Dashboard;

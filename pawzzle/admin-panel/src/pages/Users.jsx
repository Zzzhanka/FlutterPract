import { useEffect, useState } from 'react'
import { supabase } from '../supabase'

export default function Users() {
  const [users, setUsers] = useState([])

  useEffect(() => {
    fetchUsers()
  }, [])

  async function fetchUsers() {
    const { data, error } = await supabase
      .from('users')
      .select('*')

    if (!error) setUsers(data)
  }

  async function toggleBlock(user) {
    await supabase
      .from('users')
      .update({ is_blocked: !user.is_blocked })
      .eq('id', user.id)

    fetchUsers()
  }

  return (
    <div>
      <h2>Пользователи</h2>
      <table>
        <thead>
          <tr>
            <th>Email</th>
            <th>Роль</th>
            <th>Статус</th>
            <th>Действие</th>
          </tr>
        </thead>
        <tbody>
          {users.map(user => (
            <tr key={user.id}>
              <td>{user.email}</td>
              <td>{user.role}</td>
              <td>{user.is_blocked ? 'Заблокирован' : 'Активен'}</td>
              <td>
                <button onClick={() => toggleBlock(user)}>
                  {user.is_blocked ? 'Разблокировать' : 'Блокировать'}
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

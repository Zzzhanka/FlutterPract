import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Users from "./pages/Users";
import Levels from "./pages/Levels";
import ProtectedRoute from "./components/ProtectedRoute";
import Navbar from "./components/Navbar";

function Dashboard() {
  return <div style={{ padding: 20 }}>Добро пожаловать в админ-панель</div>;
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />

        <Route
          path="/"
          element={
            <ProtectedRoute>
              <>
                <Navbar />
                <Dashboard />
              </>
            </ProtectedRoute>
          }
        />

        <Route
          path="/users"
          element={
            <ProtectedRoute>
              <>
                <Navbar />
                <Users />
              </>
            </ProtectedRoute>
          }
        />

        <Route
          path="/levels"
          element={
            <ProtectedRoute>
              <>
                <Navbar />
                <Levels />
              </>
            </ProtectedRoute>
          }
        />
      </Routes>
    </BrowserRouter>
  );
}

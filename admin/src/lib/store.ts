import { create } from 'zustand';
import Cookies from 'js-cookie';

interface AuthState {
  token: string | null;
  setToken: (token: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  token: Cookies.get('admin_token') || null,
  setToken: (token: string) => {
    Cookies.set('admin_token', token, { expires: 7 });
    set({ token });
  },
  logout: () => {
    Cookies.remove('admin_token');
    set({ token: null });
  },
}));

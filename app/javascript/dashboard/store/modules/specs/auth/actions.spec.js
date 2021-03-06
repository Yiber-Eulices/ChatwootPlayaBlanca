import axios from 'axios';
import Cookies from 'js-cookie';
import { actions } from '../../auth';
import * as types from '../../../mutation-types';
import { setUser, clearCookiesOnLogout } from '../../../utils/api';
import '../../../../routes';

jest.mock('../../../../routes', () => {});
jest.mock('../../../utils/api', () => ({
  setUser: jest.fn(),
  clearCookiesOnLogout: jest.fn(),
  getHeaderExpiry: jest.fn(),
}));
jest.mock('js-cookie', () => ({
  getJSON: jest.fn(),
}));

const commit = jest.fn();
const dispatch = jest.fn();
global.axios = axios;
jest.mock('axios');

describe('#actions', () => {
  describe('#validityCheck', () => {
    it('sends correct actions if API is success', async () => {
      axios.get.mockResolvedValue({
        data: { payload: { data: { id: 1, name: 'John' } } },
        headers: { expiry: 581842904 },
      });
      await actions.validityCheck({ commit });
      expect(setUser).toHaveBeenCalledTimes(1);
      expect(commit.mock.calls).toEqual([[types.default.SET_CURRENT_USER]]);
    });
    it('sends correct actions if API is error', async () => {
      axios.get.mockRejectedValue({
        response: { status: 401 },
      });
      await actions.validityCheck({ commit });
      expect(clearCookiesOnLogout);
    });
  });

  describe('#updateProfile', () => {
    it('sends correct actions if API is success', async () => {
      axios.put.mockResolvedValue({
        data: { id: 1, name: 'John' },
        headers: { expiry: 581842904 },
      });
      await actions.updateProfile({ commit }, { name: 'Pranav' });
      expect(setUser).toHaveBeenCalledTimes(1);
      expect(commit.mock.calls).toEqual([[types.default.SET_CURRENT_USER]]);
    });
  });

  describe('#setUser', () => {
    it('sends correct actions if user is logged in', async () => {
      Cookies.getJSON.mockImplementation(() => true);
      actions.setUser({ commit, dispatch });
      expect(commit.mock.calls).toEqual([[types.default.SET_CURRENT_USER]]);
      expect(dispatch.mock.calls).toEqual([['validityCheck']]);
    });

    it('sends correct actions if user is not logged in', async () => {
      Cookies.getJSON.mockImplementation(() => false);
      actions.setUser({ commit, dispatch });
      expect(commit.mock.calls).toEqual([[types.default.CLEAR_USER]]);
      expect(dispatch).toHaveBeenCalledTimes(0);
    });
  });
});

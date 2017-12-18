package nsl.stg.core;

import java.util.ArrayList;
import java.util.List;

import nsl.stg.tests.Util;

public class UIStateManager {
	private final double SIMILARITY_THRESHOLD = 0.95;
	// private final double SIMILARITY_THRESHOLD = 0.9999;
	private List<UIState> slist;
	// reference to self
	private static UIStateManager self;

	private UIStateManager() {
		/* hide constructor */
		slist = new ArrayList<UIState>();
	}

	/**
	 *
	 * @return
     */
	public static UIStateManager getInstance() {
		if (self == null) {
			self = new UIStateManager();
		}
		return self;
	}

	/**
	 * Add s to slist
	 * @param s
     */
	public void addState(UIState s) {
		if (getState(s) == null) {
			Util.log("New UIState: " + s.dumpShort());
			slist.add(s);
		}
	}

	/**
	 *
	 * @param s UIState
	 * @return state2ret First UIState from slist (UIState list) that is computeCosineSimilarity(s) >= SIMILARITY_THRESHOLD
     */
	public UIState getState(UIState s) {
		UIState state2ret = null;
		boolean find = false;

		for (int i = 0; i < slist.size() && !find; i++) {
			UIState state = slist.get(i);

			// return on the first found
			if (state.computeCosineSimilarity(s) >= SIMILARITY_THRESHOLD) {
				state2ret = state;
				find = true;
			}
		}

		return state2ret;
	}

	/**
	 *
	 * @return s2ret First UIState from slist (UIState list) that is not fully explored
     */
	public UIState getNextTodoState() {
		UIState s2ret = null;
		boolean find = false;

		for (int i = 0; i < slist.size() && !find; i++) {
			UIState s = slist.get(i);
			if (!s.isFullyExplored()) {
				s2ret = s;
				find = true;
			}
		}

		return s2ret;
	}

	/**
	 *
	 * @return
     */
	public List<UIState> getAllTodoState() {
		List<UIState> ret = new ArrayList<UIState>();

		for (int i = 0; i < slist.size(); i++) {
			UIState s = slist.get(i);
			if (!s.isFullyExplored()) {
				ret.add(s);
			}
		}

		return ret;
	}

	/**
	 *
	 * @return
     */
	public int getExecutionSnapshot() {
		int total = 0, finished = 0;
		for (int i = 0; i < slist.size(); i++) {
			UIState s = slist.get(i);
			total += s.getTotClickables();

			int next = s.getNextClickId();
			if (next >= 0) {
				finished += next;
			}
		}

		return total + finished;
	}

	/**
	 *
	 * @return
     */
	public String dumpShort() {
		return "{" + slist.size() + " UIStates }";
	}

	/**
	 *
	 * @return
     */
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("{");

		for (int i = 0; i < slist.size(); i++) {
			UIState s = slist.get(i);
			sb.append("  " + i + " " + s.dumpShort());
		}

		sb.append("}");

		return sb.toString();
	}
}

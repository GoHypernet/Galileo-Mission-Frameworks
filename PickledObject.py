from typing import Callable
from pathlib import Path
import pickle


class PickledObject:
    """Wraps objects for easy pickling. The object in question is accessed
    directly through the `obj` member."""

    # TODO: work in args or kwargs argument so ugly lambdas can be avoided
    def __init__(self, path: str, constructor: Callable = None):
        """If a pickled object already exists at the path provided, it is
        loaded into `obj`; otherwise it is constructed according to
        the provided constructor. If neither condition is satisfied a
        ValueError exception is raised.

        :param path: Path where the pickled object should be stored and possibly loaded from.
        :param constructor: The constructor to be used if a pickled object is not already at `path`
        """
        self.path = Path(path)
        if self.path.exists():
            LOG.info("Found extant pickled object at %s", self.path.resolve())
            self.load()
        elif constructor:
            LOG.info("Constructing object for pickling")
            self.obj = constructor()
            self.dump()
        else:
            raise ValueError("Either an extant pickling or a constructor is required")

    def dump(self) -> None:
        """Pickles `obj` to `path`"""
        LOG.info("Pickling object to %s", self.path.resolve())
        pickle.dump(self.obj, self.path.open('wb'))

    def load(self) -> None:
        """Replaces `obj` with a load from `path`"""
        LOG.info("Loading pickled object from %s", self.path.resolve())
        self.obj = pickle.load(self.path.open('rb'))
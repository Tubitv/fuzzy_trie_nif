use std::cmp::min;
use std::cmp::Ordering;
use std::convert::{TryFrom, TryInto};

use rustler::types::atom::Atom;
use rustler::types::tuple::{get_tuple, make_tuple};
use rustler::{Encoder, Env, Term};

use crate::atoms;

/// SupportedTerm is an enum that covers all the Erlang / Elixir term types that can be stored in
/// a FuzzyTrie.
#[derive(Eq, Debug, Clone)]
pub enum SupportedTerm {
    Integer(i64),
    Atom(String),
    Tuple(Vec<SupportedTerm>),
    List(Vec<SupportedTerm>),
    Bitstring(String),
}

pub enum ParseSupportedError {
    UnsupportedType,
}

impl Ord for SupportedTerm {
    fn cmp(&self, other: &SupportedTerm) -> Ordering {
        match self {
            SupportedTerm::Integer(self_inner) => match other {
                SupportedTerm::Integer(inner) => self_inner.cmp(inner),
                _ => Ordering::Less,
            },
            SupportedTerm::Atom(self_inner) => match other {
                SupportedTerm::Integer(_) => Ordering::Greater,
                SupportedTerm::Atom(inner) => self_inner.cmp(inner),
                _ => Ordering::Less,
            },
            SupportedTerm::Tuple(self_inner) => match other {
                SupportedTerm::Integer(_) => Ordering::Greater,
                SupportedTerm::Atom(_) => Ordering::Greater,
                SupportedTerm::Tuple(inner) => {
                    let self_length = self_inner.len();
                    let other_length = inner.len();

                    if self_length == other_length {
                        let mut idx = 0;
                        while idx < self_length {
                            match self_inner[idx].cmp(&inner[idx]) {
                                Ordering::Less => return Ordering::Less,
                                Ordering::Greater => return Ordering::Greater,
                                _ => idx += 1,
                            }
                        }
                        Ordering::Equal
                    } else {
                        self_length.cmp(&other_length)
                    }
                }
                _ => Ordering::Less,
            },
            SupportedTerm::List(self_inner) => match other {
                SupportedTerm::Integer(_) => Ordering::Greater,
                SupportedTerm::Atom(_) => Ordering::Greater,
                SupportedTerm::Tuple(_) => Ordering::Greater,
                SupportedTerm::List(inner) => {
                    let self_length = self_inner.len();
                    let other_length = inner.len();

                    let max_common = min(self_length, other_length);
                    let mut idx = 0;

                    while idx < max_common {
                        match self_inner[idx].cmp(&inner[idx]) {
                            Ordering::Greater => return Ordering::Greater,
                            Ordering::Less => return Ordering::Less,
                            _ => idx += 1,
                        }
                    }

                    self_length.cmp(&other_length)
                }
                _ => Ordering::Less,
            },
            SupportedTerm::Bitstring(self_inner) => match other {
                SupportedTerm::Bitstring(inner) => self_inner.cmp(inner),
                _ => Ordering::Greater,
            },
        }
    }
}

impl PartialOrd for SupportedTerm {
    fn partial_cmp(&self, other: &SupportedTerm) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl PartialEq for SupportedTerm {
    fn eq(&self, other: &SupportedTerm) -> bool {
        match self {
            SupportedTerm::Integer(self_inner) => match other {
                SupportedTerm::Integer(inner) => self_inner == inner,
                _ => false,
            },
            SupportedTerm::Atom(self_inner) => match other {
                SupportedTerm::Atom(inner) => self_inner == inner,
                _ => false,
            },
            SupportedTerm::Tuple(self_inner) => match other {
                SupportedTerm::Tuple(inner) => {
                    let length = self_inner.len();

                    if length != inner.len() {
                        return false;
                    }

                    let mut idx = 0;

                    while idx < length {
                        if self_inner[idx] != inner[idx] {
                            return false;
                        }
                        idx += 1;
                    }

                    true
                }
                _ => false,
            },
            SupportedTerm::List(self_inner) => match other {
                SupportedTerm::List(inner) => {
                    let length = self_inner.len();

                    if length != inner.len() {
                        return false;
                    }

                    let mut idx = 0;

                    while idx < length {
                        if self_inner[idx] != inner[idx] {
                            return false;
                        }
                        idx += 1;
                    }

                    true
                }
                _ => false,
            },
            SupportedTerm::Bitstring(self_inner) => match other {
                SupportedTerm::Bitstring(inner) => self_inner == inner,
                _ => false,
            },
        }
    }
}

impl Encoder for SupportedTerm {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        match self {
            SupportedTerm::Integer(inner) => inner.encode(env),
            SupportedTerm::Atom(inner) => match Atom::from_str(env, inner) {
                Ok(atom) => atom.encode(env),
                Err(_) => atoms::error().encode(env),
            },
            SupportedTerm::Tuple(inner) => {
                let terms: Vec<_> = inner.iter().map(|t| t.encode(env)).collect();
                make_tuple(env, terms.as_ref()).encode(env)
            }
            SupportedTerm::List(inner) => inner.encode(env),
            SupportedTerm::Bitstring(inner) => inner.encode(env),
        }
    }
}

impl<'a> TryFrom<Term<'a>> for SupportedTerm {
    type Error = ParseSupportedError;

    fn try_from(term: Term) -> Result<Self, Self::Error> {
        if term.is_number() {
            match term.decode() {
                Ok(i) => Ok(SupportedTerm::Integer(i)),
                Err(_) => Err(ParseSupportedError::UnsupportedType),
            }
        } else if term.is_atom() {
            match term.atom_to_string() {
                Ok(a) => Ok(SupportedTerm::Atom(a)),
                Err(_) => Err(ParseSupportedError::UnsupportedType),
            }
        } else if term.is_tuple() {
            match get_tuple(term) {
                Ok(t) => {
                    if let Ok(inner_terms) = t.into_iter().map(|i: Term| i.try_into()).collect() {
                        Ok(SupportedTerm::Tuple(inner_terms))
                    } else {
                        Err(ParseSupportedError::UnsupportedType)
                    }
                }
                Err(_) => Err(ParseSupportedError::UnsupportedType),
            }
        } else if term.is_list() {
            match term.decode::<Vec<Term>>() {
                Ok(l) => {
                    if let Ok(inner_terms) = l.into_iter().map(|i: Term| i.try_into()).collect() {
                        Ok(SupportedTerm::List(inner_terms))
                    } else {
                        Err(ParseSupportedError::UnsupportedType)
                    }
                }
                Err(_) => Err(ParseSupportedError::UnsupportedType),
            }
        } else if term.is_binary() {
            match term.decode() {
                Ok(b) => Ok(SupportedTerm::Bitstring(b)),
                Err(_) => Err(ParseSupportedError::UnsupportedType),
            }
        } else {
            Err(ParseSupportedError::UnsupportedType)
        }
    }
}

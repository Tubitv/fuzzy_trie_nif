use fuzzy_trie::FuzzyTrie;
use rustler::resource::ResourceArc;
use rustler::{Atom, Env, Term};
use std::convert::{From, TryInto};
use std::sync::RwLock;
use supported_term::{ParseSupportedError, SupportedTerm};

mod supported_term;

pub struct FuzzyTrieResource(RwLock<FuzzyTrie<SupportedTerm>>);

type FuzzyTrieArc = ResourceArc<FuzzyTrieResource>;

mod atoms {
    rustler::atoms! {
        // Common Atoms
        ok,
        error,

        // Error Atoms
        lock_fail,
        unsupported_type,
    }
}

impl From<ParseSupportedError> for Atom {
    fn from(_: ParseSupportedError) -> Self {
        atoms::unsupported_type()
    }
}

rustler::init!(
    "Elixir.FuzzyTrie.Nif",
    [new, insert, len, fuzzy_search, prefix_fuzzy_search],
    load = on_load
);

// rustler initialization
fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(FuzzyTrieResource, env);
    true
}

#[rustler::nif]
pub fn new(distance: u8, damerau: bool) -> (Atom, FuzzyTrieArc) {
    let resource = ResourceArc::new(FuzzyTrieResource(RwLock::new(FuzzyTrie::new(
        distance, damerau,
    ))));

    (atoms::ok(), resource)
}

#[rustler::nif]
pub fn insert(resource: FuzzyTrieArc, key: String, term: Term) -> Result<Atom, Atom> {
    let item: SupportedTerm = term.try_into()?;

    match resource.0.write() {
        Err(_) => Err(atoms::lock_fail()),
        Ok(mut trie) => {
            trie.insert(&key).insert(item);
            Ok(atoms::ok())
        }
    }
}

#[rustler::nif]
pub fn len(resource: FuzzyTrieArc) -> Result<usize, Atom> {
    match resource.0.read() {
        Err(_) => Err(atoms::lock_fail()),
        Ok(trie) => Ok(trie.len()),
    }
}

#[rustler::nif]
pub fn fuzzy_search(resource: FuzzyTrieArc, key: String) -> Result<Vec<SupportedTerm>, Atom> {
    match resource.0.read() {
        Err(_) => Err(atoms::lock_fail()),
        Ok(trie) => {
            let mut list: Vec<&SupportedTerm> = Vec::new();
            trie.fuzzy_search(&key, &mut list);

            let result = list.iter().map(|&t| t.clone()).collect();
            Ok(result)
        }
    }
}

#[rustler::nif]
pub fn prefix_fuzzy_search(
    resource: FuzzyTrieArc,
    key: String,
) -> Result<Vec<SupportedTerm>, Atom> {
    match resource.0.read() {
        Err(_) => Err(atoms::lock_fail()),
        Ok(trie) => {
            let mut list: Vec<&SupportedTerm> = Vec::new();
            trie.prefix_fuzzy_search(&key, &mut list);

            let result = list.iter().map(|&t| t.clone()).collect();
            Ok(result)
        }
    }
}

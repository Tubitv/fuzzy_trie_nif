use fuzzy_trie::FuzzyTrie;
use rustler::resource::ResourceArc;
use rustler::{Atom, Env, Term};
use std::convert::TryInto;
use std::sync::Mutex;
use supported_term::SupportedTerm;

mod supported_term;

pub struct FuzzyTrieResource(Mutex<FuzzyTrie<SupportedTerm>>);

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
    let resource = ResourceArc::new(FuzzyTrieResource(Mutex::new(FuzzyTrie::new(
        distance, damerau,
    ))));

    (atoms::ok(), resource)
}

#[rustler::nif]
pub fn insert(resource: FuzzyTrieArc, key: String, term: Term) -> Result<Atom, Atom> {
    let item: SupportedTerm = match term.try_into() {
        Err(_) => return Err(atoms::unsupported_type()),
        Ok(term) => term,
    };

    let mut trie = match resource.0.try_lock() {
        Err(_) => return Err(atoms::lock_fail()),
        Ok(guard) => guard,
    };

    trie.insert(&key).insert(item);
    Ok(atoms::ok())
}

#[rustler::nif]
pub fn len(resource: FuzzyTrieArc) -> Result<usize, Atom> {
    let trie = match resource.0.try_lock() {
        Err(_) => return Err(atoms::lock_fail()),
        Ok(guard) => guard,
    };

    Ok(trie.len())
}

#[rustler::nif]
pub fn fuzzy_search(resource: FuzzyTrieArc, key: String) -> Result<Vec<SupportedTerm>, Atom> {
    let trie = match resource.0.try_lock() {
        Err(_) => return Err(atoms::lock_fail()),
        Ok(guard) => guard,
    };

    let mut list: Vec<&SupportedTerm> = Vec::new();
    trie.fuzzy_search(&key, &mut list);

    let result = list.iter().map(|&t| t.clone()).collect();
    Ok(result)
}

#[rustler::nif]
pub fn prefix_fuzzy_search(
    resource: FuzzyTrieArc,
    key: String,
) -> Result<Vec<SupportedTerm>, Atom> {
    let trie = match resource.0.try_lock() {
        Err(_) => return Err(atoms::lock_fail()),
        Ok(guard) => guard,
    };

    let mut list: Vec<&SupportedTerm> = Vec::new();
    trie.prefix_fuzzy_search(&key, &mut list);

    let result = list.iter().map(|&t| t.clone()).collect();
    Ok(result)
}

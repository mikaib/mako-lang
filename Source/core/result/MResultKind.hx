package core.result;

enum MResultKind<T,E> {
    Ok(t: T);
    Err(e: E);
}

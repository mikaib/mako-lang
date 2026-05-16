package core.result;
import core.result.MResultKind;
import haxe.Exception;

abstract MResult<T, E>(MResultKind<T, E>) from MResultKind<T, E> to MResultKind<T, E> {
    public function isOk(): Bool {
        return switch this {
            case Ok(_): true;
            case Err(_): false;
        }
    }

    public function isErr(): Bool {
        return switch this {
            case Ok(_): false;
            case Err(_): true;
        }
    }

    public function unwrap():T {
        return switch this {
            case Ok(o): o;
            case Err(e): throw new Exception('Internal compiler error: Result was Err with: ${e}, but got unwrapped');
        }
    }
}
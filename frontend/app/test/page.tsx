// app/test/page.tsx
"use client"; // これを追加

import { useEffect, useState } from 'react';
import { fetchTestAPI } from '../../lib/api';

export default function TestPage() {
    const [message, setMessage] = useState<string>('');

    useEffect(() => {
        async function getData() {
            try {
                const data = await fetchTestAPI();
                console.log(data.message);
                setMessage(data.message);
            } catch (error) {
                console.error('Error fetching API:', error);
            }
        }
        getData();
    }, []);

    return (
        <div>
            <h1>API Connection Test</h1>
            <p>{message}</p>
        </div>
    );
}
